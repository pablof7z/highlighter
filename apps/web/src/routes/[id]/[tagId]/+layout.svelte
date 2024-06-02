<script lang="ts">
	import { NDKVideo } from '@nostr-dev-kit/ndk';
	import { page } from '$app/stores';
	import WithItem from '$components/Event/ItemView/WithItem.svelte';
	import ItemShell from '$views/ItemShell.svelte';
	import { NDKArticle, NDKEvent, NDKUser } from '@nostr-dev-kit/ndk';
	import { loadedEvent, title } from "$stores/item-view.js"
	import { onDestroy } from 'svelte';

    let user: NDKUser;
    let tagId: string;
    let event: NDKEvent;
    let article: NDKArticle;
    let video: NDKVideo;

    $: user = $page.data.user;
    $: tagId = $page.params.tagId;

    $: {
        console.log('setting loaded event', article, video, event);
        $loadedEvent = article ?? video ?? event;
    }
    $: $title = (article || video)?.title;

    onDestroy(() => {
        console.log('removing loaded event');
        loadedEvent.set(null);
    });
</script>

<WithItem {user} {tagId} bind:event bind:article bind:video>
    {#if event}
        <ItemShell {event} title={$title}>
            <slot />
        </ItemShell>
    {/if}
</WithItem>