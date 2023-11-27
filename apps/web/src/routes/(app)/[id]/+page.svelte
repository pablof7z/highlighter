<script lang="ts">
	import { page } from "$app/stores";
	import CreatorContentGrid from "$components/CreatorContentGrid.svelte";
	import CreatorFeed from "$components/CreatorFeed.svelte";
	import CurrentSupporters from "$components/CurrentSupporters.svelte";
	import { getUserContent, getUserSupportPlansStore, getUserSupporters, userSubscription } from "$stores/user-view";
	import { Avatar, AvatarWithName, Name, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKUser, type NDKUserProfile, type NDKEventId, type Hexpubkey, NDKEvent } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";

    let id: string;
    let { npub, user } = $page.data;
    let banner = 'https://via.placeholder.com/680x382';
    let profile: NDKUserProfile | null = null;

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        npub = $page.data.npub;
        user.ndk = $ndk;

        try {
            console.log(`reqyest user`, user);
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
        <div class="relative w-full overflow-hidden" style="padding-bottom: 25%;">
            <img src={banner} class="absolute w-full h-full object-cover lg:rounded-[2rem]">
        </div>
        <!-- Profile Header -->
        <div class="flex items-end justify-between p-6 relative -top-16">
            <div class="flex items-end">
                <Avatar user={user} profile={profile} class="w-24 h-24 border-2 border-black" />
                <div class="ml-4">
                    <div class="name text-xl font-semibold text-base-100-content">
                        <Name user={user} profile={profile} />
                    </div>
                    <p class="text-sm truncate max-w-md">
                        {#if (profile?.about)}
                            {profile?.about}
                        {:else}
                            &nbsp;
                        {/if}
                    </p>
                </div>
            </div>

            <CurrentSupporters
                supporters={getUserSupporters()}
                tiers={getUserSupportPlansStore()}
                {user}
            />
        </div>

        <CreatorFeed content={getUserContent()} />
    </div>
</div>

<style lang="postcss">
    .name {
        @apply max-w-sm truncate;
    }
</style>