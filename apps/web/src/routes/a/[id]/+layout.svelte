<script lang="ts">
	import { getAuthorUrlSync } from '$utils/url';
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import { eventToKind } from "$utils/event";
	import { ndk } from "$stores/ndk.js";
	import { NDKArticle, NDKEvent, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";
	import { browser } from '$app/environment';
    import * as Content from "$components/Content";
	import WithItem from '$components/Event/ItemView/WithItem.svelte';

    let id: string;
    let event: NDKEvent | NDKArticle | NDKList | NDKVideo | undefined | null;
    
    if ($page.data.event) {
        try {
            event = new NDKEvent($ndk, $page.data.event);
            if (event) event = eventToKind(event);
        } catch {}
    }
    
    $: if (id !== $page.params.id && browser) {
        id = $page.params.id;

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

{#key id}
    <WithItem tagId={id} let:event>
        {#if event}
            <Content.Shell
                {event}
            >
                <slot />
            </Content.Shell>
        {/if}
    </WithItem>
{/key}