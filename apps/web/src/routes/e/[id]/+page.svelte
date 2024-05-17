<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import { detailView, resetLayout } from "$stores/layout";
	import { getAuthorUrlSync } from "$utils/url";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";

    let id: string;

    $detailView = null;
    
    $: id = $page.params.id;

    let event: NDKEvent | undefined;

    $: if (event) {
        const author = event.author;

        if (event.kind === event.dTag) {
            const authorUrl = getAuthorUrlSync(author);
            goto(`${authorUrl}/${event.dTag}`);
        }
    }

    onDestroy(resetLayout);
</script>

{#if id}
    {#key id}
        <ItemView bind:event tagId={id} />
    {/key}
{/if}
