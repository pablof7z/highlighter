<script lang="ts">
	import DvmTile from './DvmTile.svelte';
    import ndk from '$stores/ndk';
	import NDK, { NDKDVMRequest, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher, onDestroy } from "svelte";
    import { NDKAppHandlerEvent, type NDKDvmParam, type NDKEvent } from "@nostr-dev-kit/ndk";
	import JobRequestEditorInput from './JobRequestEditorInput.svelte';
    import JobRequestEditorPayment from './JobRequestEditorPayment.svelte';
	import { jobRequestKinds, kindToDescription, kindToText } from '$utils';
	import TypeCard from './TypeCard.svelte';
	import { ArrowFatRight, PaperPlaneTilt } from 'phosphor-svelte';
    import ParamSection from './ParamSection.svelte';
    import SelectDvms from './SelectDvms.svelte';
    import { appHandlers } from "$stores/nip89";
	import { derived, type Readable } from 'svelte/store';
	import AddInputButton from './AddInputButton.svelte';

    const dispatch = createEventDispatcher();

    export let jobRequest: NDKDVMRequest | undefined;
    export let jobs: NDKDVMRequest[] | undefined;
    export let suggestedJobRequestInput: NDKDVMRequest | undefined = undefined;

    let type: string | undefined;
    let inputTags: NDKTag[] = [];
    let outputType: string = 'text/plain';
    let amount: number = 1000;
    let params: NDKDvmParam[] = [];
    let tTags: string | undefined;
    let selectedDvms: NDKAppHandlerEvent[] = [];

    if (suggestedJobRequestInput) {
        inputTags = [ [ suggestedJobRequestInput.id, "job" ] ]
    }

    let nip89Events: Readable<NDKAppHandlerEvent[]> | undefined = undefined;

    $: if (!nip89Events && type) {
        nip89Events = derived(appHandlers, ($appHandlers) => {
            return $appHandlers.filter(h => !!h.tags.find(t => t[0] === 'k' && t[1] === type));
        })
    }

    function parseTTags(tTags: string | undefined): NDKTag[] {
        if (!tTags) return [];

        return tTags.split(/[, ]/)
            .map(tag => tag.trim().replace(/^#/, ""))
            .filter(tag => tag.length > 0)
            .map(tag => [ "t", tag ]);
    }

    async function create() {
        jobRequest = new NDKDVMRequest($ndk as NDK, {
            kind: parseInt(type!),
            tags: parseTTags(tTags),
        } as NostrEvent);

        for (const inputTag of inputTags) {
            jobRequest.addInput(...inputTag);
        }

        if (shouldShowOutput)
            jobRequest.output = outputType;


        for (const param of params) {
            jobRequest.tags.push([ "param", ...param ]);
        }

        if (selectedDvms.length > 0) {
            for (const dvm of selectedDvms) {
                jobRequest.tag(dvm.author);
            }
        }

        await jobRequest.sign();

        dispatch('created');
        await jobRequest.publish();
    }

    function cancel() {
        dispatch('cancel');
        nip89Events = undefined;
        type = undefined;
        inputTags = [[]];
        if (suggestedJobRequestInput) inputTags = [ [ suggestedJobRequestInput.id, "job" ] ];
    }

    function addInput() {
        inputTags.push([]);
        inputTags = inputTags;
    }

    function removeInput(index: number) {
        inputTags.splice(index, 1);
        inputTags = inputTags.slice();  // re-assigning to trigger a reactive update in Svelte
    }

    let shouldShowOutput = true;
    $: shouldShowOutput = type !== '5100';

    /**
     * Require selecting DVMs before moving on to show the
     * Job form
     */
    let requireSelectingDvms = false;

    const typesRequireSelectingDvms = [
        '5301',
        '5302',
    ];

    $: requireSelectingDvms = typesRequireSelectingDvms.includes(type!);
</script>

<div class="card-body flex flex-col gap-8">
    {#if !type}
        <h1 class="text-3xl border-b border-b-base-300 pb-4">Choose the job type you would like to run</h1>

        <div class="grid sm:grid-cols-2 lg:grid-cols-3 flex-wrap gap-4 justify-start">

            {#each jobRequestKinds as kind}
                <TypeCard {kind} on:click={() => { type = kind.toString(); if (type === '5301' || type === '5302') { addInput(); } }} />
            {/each}
        </div>
    {:else if requireSelectingDvms && $nip89Events}
        <SelectDvms dvms={nip89Events} bind:selectedDvms />

        <div class="card-actions">
            <button class="btn btn-accent !rounded-full btn-outline px-10" on:click={() => {requireSelectingDvms = false}}>
                CONTINUE
                <ArrowFatRight class="ml-2" />
            </button>

            <button class="btn btn-ghost" on:click={cancel}>
                Cancel
            </button>
        </div>
    {:else}
        <div class="flex flex-row gap-2 items-end whitespace-nowrap border-b border-b-base-300 pb-4">
            <h1 class="text-3xl">{kindToText(parseInt(type))}</h1>
            <h2 class="opacity-50 hidden md:block">{kindToDescription(parseInt(type))}</h2>
        </div>
        <section>

            <div class="flex flex-row items-end gap-4 mb-3 items-center">
                <AddInputButton expand={!inputTags.length && !['5301', '5302'].includes(type)} on:click={addInput} />
                <div class="flex flex-row gap-2 items-end">
                    <h3>
                        Input
                    </h3>
                    <span class="font-thin text-base opacity-50">
                        Enter the data you want to be processed
                    </span>

                </div>
            </div>

            <div class="flex flex-col gap-4">
                {#each inputTags as inputTag, index (index)}
                    <div class="flex flex-row items-start group">
                        <button class="btn btn-ghost btn-xs group-hover:opacity-100 opacity-0 absolute -ml-6 mt-2" title="remove" on:click={() => { removeInput(index) }}>
                            x
                        </button>
                        <JobRequestEditorInput bind:inputTag={inputTags[index]} {jobs} kind={parseInt(type)} />
                    </div>
                {/each}
            </div>
        </section>

        <div class="join join-vertical">
            <ParamSection kind={parseInt(type)} bind:params nip89Events={$nip89Events} />

            {#if $nip89Events && $nip89Events.length > 0}
                <details class="collapse collapse-arrow border border-base-300 bg-base-200 join-item">
                    <summary class="collapse-title">
                        <div class="flex flex-row gap-2 items-end">
                            <h3>
                                DVMs
                                {#if selectedDvms.length > 0}
                                    ({selectedDvms.length} selected)
                                {:else}
                                    ({$nip89Events.length})
                                {/if}
                            </h3>
                            <span class="font-thin text-base opacity-50">
                                Specify additional parameters
                            </span>
                        </div>
                    </summary>

                    <div class="grid grid-flow-col gap-4 collapse-content">
                        {#each $nip89Events as nip89Event (nip89Event.id)}
                            <DvmTile
                                dvm={nip89Event}
                                selected={selectedDvms.includes(nip89Event)}
                                on:selectionchanged={(selected) => {
                                    if (selected) {
                                        selectedDvms.push(nip89Event);
                                    } else {
                                        selectedDvms.splice(selectedDvms.indexOf(nip89Event), 1);
                                    }
                                    selectedDvms = selectedDvms;
                                }}
                            />
                        {/each}
                    </div>
                </details>
            {/if}

            <details class="collapse collapse-arrow border border-base-300 bg-base-200 join-item">
                <summary class="collapse-title">
                    <div class="flex flex-row gap-2 items-end">
                        <h3>
                            Advanced
                        </h3>
                    </div>
                </summary>

                <div class="collapse-content flex flex-col gap-4 divide-y divide-base-300">
                    <section>
                        <div class="flex flex-row gap-4 justify-between">
                            <div class="flex flex-col gap-2">
                                <h3 class="text-xl">
                                    Payment
                                </h3>
                                <span class="font-thin text-base opacity-50">
                                    Max you are willing to pay
                                </span>
                            </div>

                            <div class="flex-grow">
                                <JobRequestEditorPayment bind:amount />
                            </div>
                        </div>
                    </section>

                    <section>
                        <div class="flex flex-row gap-2 justify-between mb-2">
                            <div class="flex flex-col gap-2">
                                <h3>
                                    Tags
                                </h3>
                                <span class="font-thin text-base opacity-80">
                                    Some DVMs use tags to identify the jobs
                                    they can best serve.
                                    <br>
                                    E.g. if this is a bitcoin podcast,
                                    tag it <span class="text-accent font-semibold">bitcoin</span>
                                    for better discoverability.
                                </span>
                            </div>

                            <input type="text" class="input input-bordered" placeholder="tag1, tag2, tag3" bind:value={tTags} />
                        </div>
                    </section>

                    {#if shouldShowOutput}
                        <section>
                            <div class="flex flex-row gap-2 justify-between mb-2">
                                <div class="flex flex-col gap-2">
                                    <h3>
                                        Output
                                    </h3>
                                    <span class="font-thin text-base opacity-50">
                                        Specify the desired output format
                                    </span>
                                </div>

                                <input type="text" class="input input-bordered" placeholder="Desired output (mime kind)" bind:value={outputType} />
                            </div>
                        </section>
                    {/if}
                </div>
            </details>
        </div>

        <div class="card-actions">
            <button class="btn btn-accent !rounded-full btn-outline px-10" on:click={create}>
                <PaperPlaneTilt class="mr-2" />
                SUBMIT
            </button>

            <button class="btn btn-ghost" on:click={cancel}>
                Cancel
            </button>
        </div>
    {/if}
</div>

<style>
    :global(section.params) {
        @apply flex flex-col gap-1;
        @apply my-2;
    }

    :global(section.params h3) {
        @apply text-accent2;
    }

    :global(section h3, details h3) {
        @apply text-xl;
    }

    :global(.divide-y section:not(:first-child)) {
        @apply pt-4;
    }
</style>