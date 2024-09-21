<script lang="ts">
	import { getAuthorUrlSync } from '$utils/url';
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk.js";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
    import * as Content from "$components/Content";

    let id: string;
    let event: NDKEvent | undefined;
    let itemView: boolean;

    $: id = $page.params.id;
    $: itemView = !$page.params.view;
    
    if ($page.data.event) {
        try {
            event = new NDKEvent($ndk, $page.data.event);
        } catch {}
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
    <Content.Root bech32={id} {event} let:wrappedEvent>
        {#if wrappedEvent}
            <Content.Shell {itemView} {wrappedEvent}>
                <slot />
            </Content.Shell>
        {/if}
    </Content.Root>
{/key}