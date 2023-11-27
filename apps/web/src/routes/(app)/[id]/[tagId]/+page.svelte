<script lang="ts">
    import { ndk } from "@kind0/ui-common";
	import { page } from "$app/stores";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { type NDKUser, NDKKind, NDKArticle, NDKEvent, type NDKFilter } from "@nostr-dev-kit/ndk";
	import { onMount, onDestroy } from "svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import ArticleView from "./ArticleView.svelte";
	import FeedGroupPost from "$components/Feed/FeedGroupPost.svelte";

    export let user: NDKUser = $page.data.user;

    let { tagId } = $page.params;

    onMount(() => {
        startUserView(user);
    });

    onDestroy(() => {
        userSubscription?.unref();
    })

    let events: NDKEventStore<NDKEvent> | undefined;
    let event: NDKEvent | undefined;

    $: if (!events && user.pubkey) {
        const filters: NDKFilter[] = [{ authors: [user.pubkey], "#d": [tagId] }];

        // 18-char of regex
        if (tagId.match(/^0x[0-9a-fA-F]{16}$/)) {
            filters.push({ authors: [user.pubkey], "#d": [tagId.slice(2)] });
        }

        events = $ndk.storeSubscribe(filters, { groupable: false });
    }

    $: if (events) event = Array.from($events)[0];
</script>

{#if !event}
    <div class="loading"></div>
{:else}
    <div class="flex-col justify-start items-start gap-8 flex mx-auto">
        {#if event.kind === NDKKind.Article}
            <ArticleView article={NDKArticle.from(event)} />
        {:else if event.kind === NDKKind.GroupNote}
            <div class="w-full flex items-center flex-col justify-center">
                <div class="max-w-2xl mx-auto">
                    <FeedGroupPost {event} />
                </div>

            </div>
        {:else}
            {event.kind}
        {/if}
    </div>
{/if}