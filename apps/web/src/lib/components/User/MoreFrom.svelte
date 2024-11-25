<script lang="ts">
	import { Hexpubkey, NDKArticle, NDKEvent, NDKFilter, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import UserProfile from "./UserProfile.svelte";
    import { addToInbox } from "$lib/utils/user/inbox";
	import Avatar from "./Avatar.svelte";
	import Name from "./Name.svelte";
	import { derived } from "svelte/store";
	import { userFollows } from "$stores/session";
	import Button from "$components/ui/button/button.svelte";
	import { Inbox, UserPlus, ArrowRight } from "lucide-svelte";
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import ArticleCard from "$components/Card/ArticleCard.svelte";
	import { ndk } from "$stores/ndk";
	import AddToInbox from "$components/buttons/AddToInbox.svelte";

    export let user: NDKUser | undefined = undefined;
    export let pubkey: Hexpubkey | undefined = user?.pubkey;
    export let skipIds: Set<string>;
    export let filter: NDKFilter = { authors: [pubkey!]}

    const isFollowed = derived(userFollows, $userFollows => pubkey && $userFollows.has(pubkey))

    const moreContent = $ndk.storeSubscribe(
        { kinds: [NDKKind.Article], ...filter, limit: 25 },
        { closeOnEose: true },
        NDKArticle
    )

    const contentWithoutSkips = derived(moreContent, $moreContent => $moreContent.filter(i => !skipIds.has(i.tagId())))
</script>

<UserProfile {user} {pubkey} let:userProfile let:fetching let:authorUrl>
    <div class="my-10 border border-border bg-secondary/50 p-4 rounded-lg min-h-[150px] flex flex-col gap-6">
        <div class="flex flex-row gap-4">

            <a href={authorUrl} class="flex-none">
                <Avatar {userProfile} {fetching} class="rounded-lg" size="4xl" />
            </a>
            
            <div class="flex flex-col gap-2">

                <a href={authorUrl}>
                    <Name {userProfile} {fetching} class="text-2xl text-foreground font-semibold" />
                </a>

                {#if userProfile}
                    <EventContent ndk={$ndk} event={new NDKEvent()} content={userProfile.about} class="text-muted-foreground text-sm max-h-[80px[" />
                {/if}

                <div class="mt-1 flex flex-row gap-2">
                    <AddToInbox on:click={() => addToInbox(user, NDKKind.Article)}>

                    </AddToInbox>
                    
                    {#if !$isFollowed}
                        <Button variant="secondary" class="flex flex-row items-center rounded-full">
                            <UserPlus size={18} />
                        </Button>
                    {/if}
                </div>
                
            </div>
        </div>

        <div class="flex flex-row gap-4 overflow-x-auto">
            {#each $contentWithoutSkips as article}
                <ArticleCard
                    width="w-60"
                    height="h-80"
                    {article}
                    skipAuthor
                    class="grayscale hover:grayscale-0 transition-all duration-300 group"
                    imgClass="opacity-50 group-hover:opacity-100 transition-all duration-300"
                />
            {/each}
        </div>

    </div>
</UserProfile>
