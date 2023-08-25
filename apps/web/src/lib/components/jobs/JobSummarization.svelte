<script lang="ts">
    import {Avatar} from "@nostr-dev-kit/ndk-svelte-components";
	import { NDKDVMJobResult, type NDKTranscriptionDVM, } from "@nostr-dev-kit/ndk";
    import ndk from '$stores/ndk';
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";

    export let job: NDKTranscriptionDVM;

    let results: NDKEventStore<NDKDVMJobResult>;

    if (job.id) {
        results = $ndk.storeSubscribe(
            // job.filter(),
            { kinds: [5, 7000 as number, job.kind!+1000], ...job.filter() },
            { closeOnEose: true, groupableDelay: 1000 },
            NDKDVMJobResult
        )
    }
</script>

<div class="card-title text-base-100-content">
    Summarization
</div>

<div class="flex flex-row gap-2">
    {#each job.getMatchingTags('i') as input}
        {JSON.stringify(input)}
    {/each}
</div>

{#if $results}
    <ul class="menu bg-base-200 w-full rounded-box">
        {#each $results as result}
            <li>
                <Avatar ndk={$ndk} user={result.author} class="w-6 h-6" />
                {result.tagValue('status')}
                {#if result.content}
                    Display result
                {/if}
                {JSON.stringify(result.rawEvent())}
            </li>
        {/each}
    </ul>

    {$results.length}
{/if}