<script lang="ts">
	import { eventUserReference, kindToText } from "$utils";
	import type { NDKDVMRequest, NDKTag } from "@nostr-dev-kit/ndk";
	import { nip19 } from "nostr-tools";
	import { ArrowLeft } from "phosphor-svelte";

    export let jobs: NDKDVMRequest[] = [];
    export let inputTag: NDKTag | undefined = undefined;
    export let kind: number;

    let type: string = inputTag ? inputTag[1] : "";
    let value: string = inputTag ? inputTag[0] : "";

    if (type === "job") {
        type = value;
    }

    $: {
        if (type === 'url') {
            inputTag = [ value, type ];
        } else if (type === 'text') {
            inputTag = [ value, type ];
        } else if (type === 'event') {
            try {
                const decoded = nip19.decode(value);
                let id: string | undefined;

                switch (decoded.type) {
                    case 'npub':
                        id = decoded.data;
                        break;
                    case 'note':
                        id = decoded.data;
                        break;
                    case 'nevent':
                        id = decoded.data.id;
                        break;
                    case 'naddr':
                        id = [
                            decoded.data.kind,
                            decoded.data.pubkey,
                            decoded.data.identifier,
                        ].join(':');
                }

                if (id) {
                    inputTag = [ id, "event" ];
                }
            } catch (e) {
                inputTag = undefined;
            }
        } else {
            inputTag = [ type, 'job' ];
        }
    }

    let selected: string;

    if (type) {
        selected = type;
    // } else {
    //     if (kind === 65005) type = selected = "text";
    //     else if (kind === 65002) type = selected = "url";
    //     else type = selected = "event";
    }
</script>

<div class="flex flex-col gap-2 w-full">
    {#if !type || type.length === 0}
        <div class="grid sm:grid-cols-2 lg:grid-cols-3 flex-wrap gap-4 justify-start">
            <button class="card card-compact !bg-opacity-80 !bg-neutral text-neutral-content hover:!bg-opacity-100 transition-all duration-50" on:click={() => { type = 'url'}}>
                <div class="card-body text-center items-start justify-stretch">
                    <div class="card-title">
                        URL
                    </div>

                    <p class="text-left opacity-80">
                        Enter a URL of a document you want to use.
                    </p>
                </div>
            </button>

            <button class="card card-compact !bg-opacity-80 !bg-neutral text-neutral-content hover:!bg-opacity-100 transition-all duration-50" on:click={() => { type = 'event'}}>
                <div class="card-body text-center items-start justify-stretch">
                    <div class="card-title">
                        Nostr Event
                    </div>

                    <p class="text-left opacity-80">
                        <code>note1...</code>,
                        <code>nevent1...</code>,
                        <code>npub1...</code>,
                        etc
                    </p>
                </div>
            </button>

            <button class="card card-compact !bg-opacity-80 !bg-neutral text-neutral-content hover:!bg-opacity-100 transition-all duration-50" on:click={() => { type = 'text'}}>
                <div class="card-body text-center items-start justify-stretch">
                    <div class="card-title">
                        Text
                    </div>

                    <p class="text-left opacity-80">
                        Write text that will be used as input.
                    </p>
                </div>
            </button>

            {#each jobs as job, i}
                <button class="card card-compact !bg-opacity-80 !bg-neutral text-neutral-content hover:!bg-opacity-100 transition-all duration-50" on:click={() => { type = job.id }}>
                    <div class="card-body text-center items-start justify-stretch">
                        <div class="card-title text-left">
                            {kindToText(job.kind)} Result
                        </div>

                        <p class="text-left opacity-80">
                            Result of this job request
                        </p>
                    </div>
                </button>
            {/each}
        </div>
    {:else}
        <div class="flex flex-row items-center gap-2">
            <select class="select select-bordered" bind:value={type}>
                <option value="text" selected={selected === 'text'}>Text</option>
                <option value="event" selected={selected === 'event'}>Nostr Event</option>
                <option value="url" selected={selected === 'url'}>URL</option>

                {#each jobs as job, i}
                    <option value={job.id} selected={value === job.id}>Result of {kindToText(job.kind)} {eventUserReference(job)}...</option>
                {/each}
            </select>

            {#if type === 'url'}
                <input type="text" placeholder="URL" class="input input-bordered w-full" bind:value={value} autofocus />
            {:else if type === 'text'}
                <textarea rows="3" placeholder="Write some text..." class="textarea textarea-bordered w-full" bind:value={value} autofocus />
            {:else if type === 'event'}
                <input type="text" placeholder="Event ID <nevent1...>" class="input input-bordered w-full" bind:value autofocus />
            {/if}
        </div>
    {/if}
</div>