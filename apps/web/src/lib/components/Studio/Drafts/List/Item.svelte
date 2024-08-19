<script lang="ts">
	import { DraftItem } from "$stores/drafts";

    import Studio from './types/Studio.svelte';
    import Composer from './types/Composer.svelte';

    import RelativeTime from '$components/PageElements/RelativeTime.svelte';
    import { Button } from '$components/ui/button';
    import { Timer, Trash } from "phosphor-svelte";
	import { getDraftItemCheckpoints, getStateFromDraft } from "$components/Studio/draft";
	import { deleteDraft } from "$utils/drafts";
	import Versions from "../Item/Versions.svelte";

    export let item: DraftItem;

    const checkpoints = getDraftItemCheckpoints(item);
</script>

<div class="flex flex-col gap-2">
    <div class="overflow-hidden">
        {#if item.type === 'studio' || item.type === 'article'}
            <Studio {item} />
        {:else if item.type === 'composer'}
            <Composer {item} />
        {:else}
            Unknown type: {item.type}
        {/if}
    </div>
    <div class="flex flex-row justify-between items-center px-4">
        <Button variant="secondary" class="gap-0 flex flex-row items-center group whitespace-nowrap" on:click={() => deleteDraft(item.id)}>
            <Trash class="w-5 h-5" weight="light" />
            <span class="max-w-0 truncate group-hover:max-w-[5rem] text-foreground whitespace-nowrap line-clamp-1 ml-2 transition-all duration-300">
                Delete
            </span>
        </Button>

        <Versions {item} />
    </div>
    <div class="text-xs font-light opacity-50 text-center w-full">
        <RelativeTime timestamp={checkpoints[0].time} />
    </div>
</div>