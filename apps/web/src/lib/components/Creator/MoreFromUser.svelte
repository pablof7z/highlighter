<script lang="ts">
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import PostGrid from "$components/Events/PostGrid.svelte";
	import VideoLink from "$components/Events/VideoLink.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { Name, ndk } from "@kind0/ui-common";
    import { NDKKind, type NDKFilter, type NDKUser, NDKSubscriptionCacheUsage, NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";

    export let user: NDKUser;

    const filters: NDKFilter[] = [
        {
            kinds: [ NDKKind.Article, NDKKind.HorizontalVideo ],
            authors: [user.pubkey],
        }
    ];
    const events = $ndk.storeSubscribe(
        filters,
    { autoStart: true, groupable: false, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY })

    onDestroy(() => {
        events.unsubscribe();
    })
</script>

<UserProfile {user} let:userProfile let:fetching>
    <div class="bg-base-200 rounded-box p-6 flex flex-col w-full gap-10">
        <h1 class="text-white font-semibold text-2xl">
            More from
            <Name {userProfile} {fetching} />
        </h1>

        <div class="grid grid-flow-row lg:grid-flow-col gap-10 overflow-x-auto pb-4 overflow-y-hidden snap-x snap-mandatory">
            {#each $events as event (event.id)}
                <div class="w-80 snap-center">
                    {#if event.kind === NDKKind.Article}
                        <ArticleLink article={NDKArticle.from(event)} skipAuthor={true} grid={true} />
                    {:else if event.kind === NDKKind.HorizontalVideo}
                        <VideoLink video={NDKVideo.from(event)} skipAuthor={true} grid={true} />
                    {:else if event.kind === NDKKind.GroupNote}
                        <PostGrid {event} />
                    {/if}
                </div>
            {/each}
        </div>
    </div>
</UserProfile>