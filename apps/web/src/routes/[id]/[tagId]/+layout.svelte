<script lang="ts">
	import { NDKVideo } from '@nostr-dev-kit/ndk';
	import { page } from '$app/stores';
	import WithItem from '$components/Event/ItemView/WithItem.svelte';
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
        $loadedEvent = article ?? video ?? event;
    }
    $: $title = (article || video)?.title;

    onDestroy(() => {
        loadedEvent.set(null);
    });
</script>

<WithItem {user} {tagId} bind:event bind:article bind:video>
    {#if $loadedEvent}
        <slot />
    {/if}
</WithItem>