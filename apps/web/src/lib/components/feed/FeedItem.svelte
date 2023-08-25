<script lang="ts">
	import ndk from "$stores/ndk";
    import { nip19 } from 'nostr-tools';
	import { type NDKEvent, type NDKTag } from "@nostr-dev-kit/ndk";
	import { Avatar, Name } from "@nostr-dev-kit/ndk-svelte-components";
	import PaymentRequiredButton from "$components/jobs/PaymentRequiredButton.svelte";
	import { kindToText } from "$utils";
	import Time from "svelte-time/src/Time.svelte";

    export let item: NDKEvent;
    export let events: NDKEvent[] = [];
    export let dependentJobs: NDKEvent[] | undefined = undefined;

    let jobRequestId: string | undefined;
    let inputs: NDKTag[] = [];

    if (item.kind! >= 6000 || item.kind! <= 7000) {
        jobRequestId = item.tagValue('e');
        if (jobRequestId) {
            jobRequestId = nip19.noteEncode(jobRequestId);
        }
    } else {
    }

    $: dependentJobs = calcDependentJobs(item);

    function calcDependentJobs(item: NDKEvent) {
        const dependentJobs: NDKEvent[] = [];

        events.forEach(event => {
            if (event.getMatchingTags('i').some(i => i[1] === item.tagId() && i[2] === 'job')) {
                dependentJobs.push(event);
            }
        });

        return dependentJobs;
    }

    inputs = item.getMatchingTags('i');

    function useRelativeTime() {
        const now = Date.now();
        const diff = now - item.created_at!*1000;

        return diff < 1000*60*60*24;
    }

    function encodeInput(input: NDKTag) {
        try {
            const id = input[1];
            let encodedId;

            if (id.match(/:/)) {
                const [ kind, pubkey, identifier ] = id.split(/:/);
                encodedId = nip19.naddrEncode({
                    kind: parseInt(kind),
                    pubkey,
                    identifier
                });
            } else {
                encodedId = nip19.noteEncode(id);
            }

            return encodedId;
        } catch (e) {
            console.error(e);
        }
    }

    let dvms: Record<string, NDKEvent[]> = {};

    $: if (events) {
        events.forEach(event => {
            if (event.kind! >= 6000 && event.kind! <= 7000) {
                const dvmPubkey = event.pubkey;
                if (!dvms[dvmPubkey]) dvms[dvmPubkey] = [];
                if (dvms[dvmPubkey].some(e => e.id === event.id)) return;


                dvms[dvmPubkey].push(event);
            }
        })

        events = events;
    }

    // $: $jobRequests.forEach(jobRequest => {
    //     if (
    //         jobRequest.getMatchingTags("i").forEach(input => {
    //             if (input[2] === 'job') {
    //                 const id = input[1];
    //                 let encodedId;

    //                 if (id.match(/:/)) {
    //                     const [ kind, pubkey, identifier ] = id.split(/:/);
    //                     encodedId = nip19.naddrEncode({
    //                         kind: parseInt(kind),
    //                         pubkey,
    //                         identifier
    //                     });
    //                 } else {

    //                 }
    //             }
    //         })
    //         !ids.includes(r.encode())
    //     ) {
    //         goto(`/jobs/${[...ids, r.encode()].join(',')}`);
    //     }
    // });
</script>

<div class="card card-compact">
    <div class="card-body flex flex-col gap-2 w-full">
        <div class="flex flex-row w-full justify-between mb-4">
            <span>
                ID: #{item.id.slice(0, 3)}
            </span>

            <span>
                <Time
                    relative={useRelativeTime()}
                    timestamp={item.created_at*1000}
                    class="text-sm whitespace-nowrap"
                />
            </span>
        </div>
        <div class=" flex flex-row gap-4 items-center">
            <Avatar ndk={$ndk} pubkey={item.pubkey} class="w-12 h-12 rounded-full overflow-hidden" />
            <Name ndk={$ndk} pubkey={item.pubkey} class="font-semibold" />

            <div class="flex-grow"></div>

            <div class="flex flex-col">
                {#if item.kind >= 6000 && item.kind < 7000}
                    <a class="btn btn-neutral" >
                        Result
                    </a>
                {:else if item.kind === 7000}
                    {#if !['payment-required'].includes(item.tagValue('status'))}
                        <span>
                            {item.content}
                            {item.tagValue('status')}
                            {#if jobRequestId}
                                <a href="/jobs/{jobRequestId}/">
                                    #{jobRequestId.slice(0, 3)}
                                </a>
                            {/if}
                        </span>
                    {/if}
                {:else}
                    <a class="btn btn-neutral" href="/jobs/{item.encode()}">{kindToText(item.kind)}</a>
                {/if}

                {#if item.tagValue('status') === 'payment-required'}
                    <PaymentRequiredButton
                        event={item}
                    />
                {/if}
            </div>
        </div>

        <div class="flex flex-row gap-4 w-full">
            {#if item.tagValue('image')}
                <img src={item.tagValue('image')} class="w-24 h-24 object-cover rounded-lg" />
            {/if}

            <div class="flex flex-col gap-2 truncate">
                {#each inputs as input}
                    <p class="font-regular">
                        <span class="text-base-100-content">input:</span>
                        {#if input[2] === 'job'}
                            output of
                            <a href="/jobs/{encodeInput(input)}" class="text-accent">
                                #{input[1]?.slice(0, 8)}
                            </a>
                            (job chaining)
                        {:else if input[2] === 'event'}
                            #{input[1]?.slice(0, 8)}
                        {:else}
                            {input[1]}
                        {/if}
                    </p>
                {/each}

                {#if item.tagValue('output')}
                    <p class="font-regular">
                        <span class="text-base-100-content">output:</span>
                        {item.tagValue('output')}
                    </p>
                {/if}
            </div>
        </div>

        <div class="flex flex-col bg-base-100 p-4">
            {#each Object.entries(dvms) as [dvmPubkey, events]}
                <div class="flex flex-row gap-2 items-center">
                    <Avatar ndk={$ndk} pubkey={dvmPubkey} class="w-12 h-12 rounded-md" />
                    <Name ndk={$ndk} pubkey={dvmPubkey} />
                </div>

                <div class="flex flex-col divide-y divide-base-100">
                    {#each events as event}
                        <div class="whitespace-normal text-lg my-6">{event.content}</div>
                        {#if event.kind >= 6000 && event.kind < 7000}
                            <a class="btn btn-neutral" >
                                Result
                            </a>
                        {/if}
                        {#if !['payment-required'].includes(event.tagValue('status'))}
                            <span>
                                {event.content}
                                {event.tagValue('status')}
                                {#if jobRequestId}
                                    <a href="/jobs/{jobRequestId}/">
                                        #{jobRequestId.slice(0, 3)}
                                    </a>
                                {/if}
                            </span>
                        {/if}

                        {#if event.tagValue('status') === 'payment-required'}
                            <PaymentRequiredButton
                                event={event}
                            />
                        {/if}
                    {/each}
                </div>
            {/each}
        </div>
    </div>
</div>

{#if dependentJobs?.length > 0}
    <div class="flex flex-col gap-2 ml-10">
        {#each dependentJobs as dependentJob}
            <svelte:self item={dependentJob} {events} />
        {/each}
    </div>
{/if}