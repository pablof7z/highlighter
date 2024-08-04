<script lang="ts">
	import { NDKVideo } from '@nostr-dev-kit/ndk';
	import { page } from '$app/stores';
	import WithItem from '$components/Event/ItemView/WithItem.svelte';
	import { NDKArticle, NDKEvent, NDKUser } from '@nostr-dev-kit/ndk';
	import { layout } from '$stores/layout';

    let user: NDKUser;
    let tagId: string;
    let event: NDKEvent;
    let article: NDKArticle;
    let video: NDKVideo;

    $: user = $page.data.user;
    $: tagId = $page.params.tagId;

    let authorUrl: string;

    $: $layout.back = { url: authorUrl }
</script>

<WithItem {user} {tagId} bind:authorUrl bind:event bind:article bind:video>
        <slot />
</WithItem>