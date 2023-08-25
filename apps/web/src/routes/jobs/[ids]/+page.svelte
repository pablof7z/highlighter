<script lang="ts">
	import { page } from '$app/stores';
    import JobRequestCard from '$components/jobs/JobRequestCard.svelte';
	import ndk from '$stores/ndk';
	import { NDKDVMRequest, NDKEvent } from '@nostr-dev-kit/ndk';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { nip19 } from 'nostr-tools';
	import JobRequestEditor from '$components/jobs/JobRequestEditor/JobRequestEditor.svelte';
    import { writable } from 'svelte/store';

    const relatedJobRequests = writable<Set<NDKEvent[]>>(new Set());

    let prevIds: string;
    let ids: string[];

    let jobRequests: NDKEventStore<NDKDVMRequest>;

    $: if (prevIds !== $page.params.ids) {
        prevIds = $page.params.ids;
        ids = $page.params.ids.split(/,/);

        const hexids = [];

        for (const id of ids) {
            const decoded = nip19.decode(id);

            switch (decoded.type) {
                case 'nevent':
                    hexids.push(decoded.data.id);
                    break;
                case 'note':
                    hexids.push(decoded.data);
                    break;
            }
        }

        jobRequests = $ndk.storeSubscribe<NDKDVMRequest>(
            { "ids": hexids },
            { closeOnEose: true },
            NDKDVMRequest
        );
    }
</script>

<div class="flex flex-col gap-8">
    <div class="flex flex-col gap-2">
        {#each $jobRequests as jobRequest (jobRequest)}
            <JobRequestCard jobRequest={jobRequest} relatedJobRequests={relatedJobRequests} />
        {/each}
    </div>
</div>