<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import { resetLayout } from "$stores/layout";
	import { getAuthorUrlSync } from "$utils/url";
	import { ndk } from "$stores/ndk.js";
	import { NDKArticle, NDKEvent, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { eventToKind } from "$utils/event";

    let id: string;
    let event: NDKEvent | NDKArticle | NDKList | NDKVideo | undefined | null;
    
    $: if (id !== $page.params.id) {
        id = $page.params.id;

        $ndk.fetchEvent(id).then((e) => {
            event = e ? eventToKind(e) : null;
        });
    }

    $: if (event) {
        const author = event.author;

        if (event.kind === event.dTag) {
            const authorUrl = getAuthorUrlSync(author);
            goto(`${authorUrl}/${event.dTag}`);
        }
    }

    onDestroy(resetLayout);
</script>

<LoadingScreen ready={event !== undefined}>
    {#key event?.id}
        {#if event}
            <ItemView {event} ignoreHeader={true}  />
        {/if}
    {/key}
</LoadingScreen>