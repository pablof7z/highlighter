<script lang="ts">
    import Button from "$components/ui/button/button.svelte";
import * as DropdownMenu from "$components/ui/dropdown-menu";
	import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { DotsThreeVertical, TrashSimple } from "phosphor-svelte";

    import Delete from "./Delete.svelte";
	import Copy from "./Copy.svelte";
	import Edit from "./Edit.svelte";

    export let size: "tiny" | "normal"  = "normal";
    export let event: NDKEvent;
    let open = false;

    let pixels: number;
    export let padding = '1rem';

    $: switch (size) {
        case "tiny":
            pixels = 24;
            padding = '3px';
            break;
        case "normal":
            pixels = 30;
            padding = '0.25rem';
            break;
    }
</script>

<DropdownMenu.Root bind:open>
    <DropdownMenu.Trigger>
        <Button variant="secondary" class="!bg-opacity-50 rounded-sm" style="width: {pixels}px; height: {pixels}px; padding: {padding}">
            <DotsThreeVertical class="w-full h-full !text-muted-foreground" />
        </Button>
    </DropdownMenu.Trigger>
    <DropdownMenu.Content>
        <Edit {event} />
        
        <!-- {#if event.kind === NDKKind.Article}
            <DropdownMenu.Group>
                <SaveForLater {event} />
            </DropdownMenu.Group>
        {/if} -->
        
        <DropdownMenu.Group>
            <Copy bind:open payload={event.encode()}>Copy ID</Copy>
            <Copy bind:open payload={event.rawEvent()}>Copy raw data</Copy>

            <Delete {event} on:delete on:delete:cancel />
        </DropdownMenu.Group>
    </DropdownMenu.Content>
</DropdownMenu.Root>