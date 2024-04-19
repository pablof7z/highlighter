<script lang="ts">
	import { page } from "$app/stores";
	import CreatorFeed from "$components/Feed/CreatorFeed.svelte";
	import { userSubscription, getUserSubscriptionTiersStore } from "$stores/user-view";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKEventId } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import { onMount } from "svelte";
    import { addReadReceipt } from "$utils/read-receipts";
	import { pageHeader } from '$stores/layout';
	import type { UserProfileType } from '../../app';

    let id: string;
    let { user } = $page.data;

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        user.ndk = $ndk;
    }

    onMount(() => {
        addReadReceipt(user);
    })

    let articles: Readable<Map<NDKEventId, NDKArticle>>;

    $: if (!articles && userSubscription && $userSubscription) {
        articles = derived(userSubscription, $userSubscription => {
            const articles = new Map<NDKEventId, NDKArticle>();

            for (const event of $userSubscription) {
                if (
                    event.pubkey !== user.pubkey ||
                    event.kind !== NDKKind.Article
                ) continue;

                const id = event.encode();
                if (!articles.has(id)) articles.set(id, NDKArticle.from(event));
            }

            return articles;
        });
    }

    let userProfile: UserProfileType;

    $: $pageHeader = {}
</script>

<svelte:head>
    <title>{userProfile?.name ?? id} on Highlighter</title>
    <meta name="description" content="Creator profile" />
    <meta property="og:title" content={user.npub} />
    <meta property="og:description" content="Creator profile" />
    {#if userProfile?.banner}
        <meta property="og:image" content={userProfile.banner} />
    {/if}
</svelte:head>

<CreatorFeed />