<script lang="ts">
	import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
    import * as DropdownMenu from "$components/ui/dropdown-menu";
	import { Pen } from "phosphor-svelte";
	import { goto } from "$app/navigation";
	import currentUser from "$stores/currentUser";

    export let event: NDKEvent;

    let canEdit: boolean;

    const editableKinds = new Set([
        NDKKind.Article,
    ]);
    
    $: canEdit = $currentUser?.pubkey === event.pubkey && editableKinds.has(event.kind!);

    function clicked() {
        switch (event.kind) {
            case NDKKind.Article:
                goto(`/studio/article?eventId=${event.encode()}`)
                break;
        }
    }
</script>

{#if canEdit}
    <DropdownMenu.Item on:click={clicked}>
        <Pen class="w-5 h-5 mr-2" />
        Edit
    </DropdownMenu.Item>
{/if}