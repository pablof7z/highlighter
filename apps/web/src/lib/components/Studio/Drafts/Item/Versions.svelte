<script lang="ts">
	import { DraftItem } from "$stores/drafts";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
	import { ClockCounterClockwise } from "phosphor-svelte";
	import { Button } from "$components/ui/button";
	import { getDraftItemCheckpoints, getStateFromDraft } from "$components/Studio/draft";
	import VersionList from "../List/VersionList.svelte";
	import { ScrollArea } from "$components/ui/scroll-area";

    export let item: DraftItem;
    export let variant = 'outline'

    let type: string;

    type = item.type;
    if (item.type === 'studio') {
        const state = getStateFromDraft(item);
        type = state.type;
    }

    const checkpoints = getDraftItemCheckpoints(item);
</script>

<DropdownMenu.Root>
    <DropdownMenu.Trigger asChild let:builder>
        <Button builders={[builder]} {variant}>
            <ClockCounterClockwise class="w-5 h-5" />
        </Button>
    </DropdownMenu.Trigger>

    <DropdownMenu.Content class="absolute z-[999999]">
        <ScrollArea orientation="vertical" class=''>
            <div class="h-max overflow-x-clip overflow-y-auto max-h-[50dvh]">
                <DropdownMenu.Group>
                    {#each checkpoints as checkpoint}
                        <DropdownMenu.Item>
                            <VersionList {type} {item} {checkpoint} />
                        </DropdownMenu.Item>
                    {/each}
                </DropdownMenu.Group>
            </div>
        </ScrollArea>
    </DropdownMenu.Content>
</DropdownMenu.Root>