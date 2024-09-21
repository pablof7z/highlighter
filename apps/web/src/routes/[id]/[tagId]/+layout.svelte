<script lang="ts">
	import { NDKVideo } from '@nostr-dev-kit/ndk';
	import { page } from '$app/stores';
	import { NDKArticle, NDKEvent, NDKUser } from '@nostr-dev-kit/ndk';
	import { layout } from '$stores/layout';
    import * as Content from '$components/Content';

    let user: NDKUser;
    let tagId: string;
    let event: NDKEvent;
    let article: NDKArticle;
    let video: NDKVideo;
    let itemView: boolean;

    $: user = $page.data.user;
    $: tagId = $page.params.tagId;
    $: itemView = !$page.params.view;

    let authorUrl: string;

    $: $layout.back = { url: authorUrl }
</script>

{#key tagId}
    <Content.Root {user} dTag={tagId} let:wrappedEvent>
        {#if wrappedEvent}
            <Content.Shell {itemView} {wrappedEvent}>
                <slot />
            </Content.Shell>
        {/if}
    </Content.Root>
{/key}