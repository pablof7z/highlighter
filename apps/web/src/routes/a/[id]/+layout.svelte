<script lang="ts">
	import { getAuthorUrlSync } from '$utils/url';
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import { loadedEvent } from "$stores/item-view";
	import { eventToKind } from "$utils/event";
	import { ndk } from "$stores/ndk.js";
	import { NDKArticle, NDKEvent, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";

    let id: string;
    let event: NDKEvent | NDKArticle | NDKList | NDKVideo | undefined | null;
    
    if ($page.data.event) {
        try {
            event = new NDKEvent($ndk, $page.data.event);
            if (event) event = eventToKind(event);
        } catch {}
    }
    
    $: $loadedEvent = event;

    $: if (id !== $page.params.id) {
        id = $page.params.id;

        console.log('loading event '+id);
        
        $ndk.fetchEvent(id).then((e) => {
            console.log('back with ', e?.rawEvent())
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
</script>

<slot />