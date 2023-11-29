<script lang="ts">
	import { page } from "$app/stores";
	import CreatorFeed from "$components/CreatorFeed.svelte";
	import CurrentSupporters from "$components/CurrentSupporters.svelte";
	import { getUserContent, userTiers, getUserSupporters, userSubscription, userContent } from "$stores/user-view";
	import { Avatar, Name, UserProfile, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKUserProfile, type NDKEventId } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";

    let id: string;
    let { user } = $page.data;
    const defaultBanner = 'https://tonygiorgio.com/content/images/2023/03/cypherpunk-ostrach--copy--2.png';

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        user.ndk = $ndk;

        try {
            user.fetchProfile({ groupable: false }).then((p) => {
                profile = p;
                if (profile?.banner) banner = profile.banner;
            }).catch((e) => {
                console.log(e, ` error`);
            });
        } catch(e) {
            console.log(e, ` error`);
        }
    }

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
</script>

<div class="max-w-5xl mx-auto">
    <div class="">
        <UserProfile {user} let:userProfile let:fetching>
            <div class="relative w-full overflow-hidden" style="padding-bottom: 25%;">
                <img src={userProfile?.banner??defaultBanner} class="absolute w-full h-full object-cover object-top lg:rounded-[2rem]">
            </div>
            <!-- Profile Header -->
            <div class="flex items-end justify-between p-6 relative -top-16">
                <div class="flex items-end">

                    <Avatar user={user} {userProfile} {fetching} class="w-24 h-24 border-2 border-black" />

                    <div class="ml-4">
                        <div class="name text-xl font-semibold text-base-100-content">
                            <Name {userProfile} {fetching} />
                        </div>
                        <p class="text-sm truncate max-w-md">
                            {#if fetching}
                                <div class="skeleton h-15 w-48"></div>
                            {:else if userProfile.about}
                                {userProfile?.about}
                            {:else}
                                &nbsp;
                            {/if}
                        </p>
                    </div>
                </div>

                {#if $userTiers}
                    <CurrentSupporters
                        supporters={getUserSupporters()}
                        tiers={$userTiers}
                        {user}
                    />
                {/if}
            </div>
        </UserProfile>

        {#if $userContent}
            <CreatorFeed content={$userContent} />
        {/if}
    </div>
</div>

<style lang="postcss">
    .name {
        @apply max-w-sm truncate;
    }
</style>