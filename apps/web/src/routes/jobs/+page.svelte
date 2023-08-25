<script lang="ts">
	import { NDKDVMRequest, type NDKEvent } from '@nostr-dev-kit/ndk';
	import JobRequestCard from '$components/jobs/JobRequestCard.svelte';
    import ndk from '$stores/ndk';
	import { derived } from 'svelte/store';
	import { jobRequestKinds } from '$utils';
	import { onDestroy } from 'svelte';

    const allJobRequests = $ndk.storeSubscribe<NDKDVMRequest>(
        { kinds: jobRequestKinds, limit: 20 },
        { closeOnEose: false, subId: 'all-job-requests' },
        NDKDVMRequest
    );

    onDestroy(() => {
        allJobRequests.unsubscribe();
    })

    function isTopLevelItem(item: NDKEvent) {
        const hasJobAsInput = item.getMatchingTags('i').some(input => {
            return input[2] === 'job';
        });

        return !hasJobAsInput;
    }

    const sortedJobRequests = derived(allJobRequests, ($allJobRequests) => {
        return $allJobRequests.sort((a, b) => {
            return b.created_at - a.created_at;
        });
    });
</script>

<div class="max-w-3xl mx-auto list-container">
    <div class="mx-auto flex flex-col gap-4">
        <h1 class="
            text-5xl md:text-7xl text-center font-black
            bg-clip-text !text-transparent bg-gradient-to-r from-gradient3 to-gradient4
        ">Global Feed</h1>
        <div class="text-lg md:text-2xl text-base-100-content font-extralight text-center">
            This is a feed of all the DVM jobs that have been recently created
        </div>
    </div>

    {#if $sortedJobRequests}
        {#each $sortedJobRequests.slice(0, 50) as jobRequest (jobRequest.id)}
            {#if isTopLevelItem(jobRequest)}
                <JobRequestCard {jobRequest} compact={true} />
            {/if}
        {/each}
    {/if}
</div>

