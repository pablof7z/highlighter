<script lang="ts">
	import type { NDKEvent } from '@nostr-dev-kit/ndk';
    import { currentUser } from '$stores/current-user';
    import { userJobRequests } from '$stores/jobRequests';
	import JobRequestCard from '$components/jobs/JobRequestCard.svelte';
	import { derived, type Readable } from 'svelte/store';

    function isTopLevelItem(item: NDKEvent) {
        const hasJobAsInput = item.getMatchingTags('i').some(input => {
            return input[2] === 'job';
        });

        return !hasJobAsInput;
    }

    let sortedJobRequests: Readable<NDKEvent[]> | undefined;

    $: if (!sortedJobRequests && $currentUser) {
        sortedJobRequests = derived(userJobRequests, ($userJobRequests) => {
            return $userJobRequests.sort((a, b) => {
                return b.created_at - a.created_at;
            });
        });
    }
</script>

<div class="max-w-5xl mx-auto flex flex-col gap-6">
    <div class="mx-auto flex flex-col gap-4">
        <h1 class="
            text-7xl text-center font-black
            bg-clip-text !text-transparent bg-gradient-to-r from-gradient3 to-gradient4
        ">Your DVM Jobs</h1>
        <div class="text-2xl text-base-100-content font-extralight text-center">
            This is a feed of all your DVM jobs
        </div>
    </div>

    <div class="list-container">
        {#if $sortedJobRequests && $sortedJobRequests.length > 0}
            {#each $sortedJobRequests as jobRequest (jobRequest.id)}
                <JobRequestCard {jobRequest} compact={true} />
            {/each}
        {/if}
    </div>
</div>

