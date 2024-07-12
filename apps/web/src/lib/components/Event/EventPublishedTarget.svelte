<script lang="ts">
	import Badge from "$components/ui/badge/badge.svelte";
import { NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";
    import * as Group from "$components/Groups";
	import { get } from "svelte/store";

    export let event: NDKEvent;

    const hTags: NDKTag[] = event.getMatchingTags("h");
</script>

{#if hTags.length > 0}
    {#each hTags as hTag}
        <Group.Root tag={hTag} let:group let:metadata>
            <div class="bg-secondary rounded-2xl flex flex-row text-xs pr-2">
                <img src={get(metadata)?.picture} class="w-4 h-4 rounded-full object-cover mr-1" />
                {get(metadata)?.name}
            </div>
        </Group.Root>
    {/each}
{/if}