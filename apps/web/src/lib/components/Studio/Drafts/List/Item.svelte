<script lang="ts">
	import { DraftItem } from "$stores/drafts";

    import Studio from './types/Studio.svelte';
    import Composer from './types/Composer.svelte';

    import VersionList from './VersionList.svelte';
    
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
    import RelativeTime from '$components/PageElements/RelativeTime.svelte';
    import { Button } from '$components/ui/button';
    import { Timer, Trash } from "phosphor-svelte";
	import { getDraftItemCheckpoints, getStateFromDraft } from "$components/Studio/draft";
	import { deleteDraft } from "$utils/drafts";

    export let item: DraftItem;
    const checkpoints = getDraftItemCheckpoints(item);

    let type: string;

    type = item.type;
    if (item.type === 'studio') {
        const state = getStateFromDraft(item);
        type = state.type;
    }
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

        <DropdownMenu.Root>
            <DropdownMenu.Trigger asChild let:builder>
                <Button builders={[builder]} variant="outline">
                    <Timer class="w-5 h-5 mr-2" />
                    Versions
                </Button>
            </DropdownMenu.Trigger>

            <DropdownMenu.Content class="absolute z-[999999]">
                <DropdownMenu.Group>
                    {#each checkpoints as checkpoint}
                        <DropdownMenu.Item>
                            <VersionList {type} {item} {checkpoint} />
                        </DropdownMenu.Item>
                    {/each}
                </DropdownMenu.Group>
            </DropdownMenu.Content>
        </DropdownMenu.Root>
    </div>
    <div class="text-xs font-light opacity-50 text-center w-full">
        <RelativeTime timestamp={checkpoints[0].time} />
    </div>
</div>