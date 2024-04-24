<script lang="ts">
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;

    const tags = event.getMatchingTags("t").map(t => t[1]);
    const hasTags = tags.length > 0;
</script>

{#if hasTags}
    <div class="overflow-hidden">
        <div class="
            flex flex-row gap-4 flex-nowrap
            snap snap-x snap-start snap-mandatory
        ">
            {#each tags as tag, i (i)}
                <div
                    href="/?q={encodeURIComponent("#"+tag)}"
                    class="flex-row gap-2 text-white/50 text-sm inline flex-inline bg-white/10 rounded-full px-3 py-1 whitespace-nowrap snap-center"
                >
                    <span>{tag}</span>
                </div>
            {/each}
        </div>
    </div>
{/if}