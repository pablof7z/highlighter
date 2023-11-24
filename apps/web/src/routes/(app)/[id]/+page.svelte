<script lang="ts">
	import { page } from "$app/stores";
	import CreatorContentGrid from "$components/CreatorContentGrid.svelte";
	import CurrentSupporters from "$components/CurrentSupporters.svelte";
	import { getUserContent, getUserSupportPlansStore, getUserSupporters, userSubscription } from "$stores/user-view";
	import { Avatar, AvatarWithName, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKUser, type NDKUserProfile, type NDKEventId, type Hexpubkey } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";

    let { id } = $page.params;
    let { npub } = $page.data;
    let user: NDKUser;
    let promise: Promise<NDKUserProfile | null>;

    $: {
        id = $page.params.id;
        npub = $page.data.npub;

        if (npub.startsWith('npub')) {
            try {
                user = $ndk.getUser({npub})
                promise = new Promise((resolve, reject) => {
                    user.fetchProfile().then((profile) => {
                        resolve(profile)
                    }).catch((e) => {
                        reject(e)
                    });
                })
            } catch(e) {
                console.log(e, ` error`);
            }
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

{#if promise}
    {#await promise}
    trying
    {:then profile}
        <div class="">
            <div class="relative w-full overflow-hidden" style="padding-bottom: 25%;">
                <img src={profile.banner} class="absolute w-full h-full object-cover lg:rounded-[2rem]">
            </div>
            <!-- Profile Header -->
            <div class="flex items-end justify-between p-6 relative -top-16">
                <div class="flex items-end">
                    <Avatar user={user} profile={profile} class="w-24 h-24 border-2 border-black" />
                    <div class="ml-4">
                        <p class="text-xl font-semibold text-base-100-content">{profile.name}</p>
                        <p class="text-sm truncate max-w-md">{profile.about}</p>
                    </div>
                </div>

                <CurrentSupporters
                    supporters={getUserSupporters()}
                    tiers={getUserSupportPlansStore()}
                    {user}
                />
            </div>

            <CreatorContentGrid content={getUserContent()} />
        </div>
    {:catch error}
        <p>{error.message}</p>
    {/await}
{/if}