<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { blacklistedPubkeys } from "$utils/const";
	import { mainContentKinds } from "$utils/event";
import { Avatar, ndk } from "@kind0/ui-common";
	import { type Hexpubkey, NDKKind, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";

    const events = $ndk.storeSubscribe([
        { kinds: [NDKKind.SubscriptionTier] },
        { kinds: mainContentKinds, "#f": ["Free"]}
    ], { closeOnEose: true });

    onDestroy(() => {
        events.unsubscribe();
    });

    const creators = derived(events, $events => {
        const creators = new Set<Hexpubkey>();
        const creatorsWithFreeContent = new Set<Hexpubkey>();

        for (const event of $events) {
            if (blacklistedPubkeys.includes(event.pubkey)) continue;

            switch (event.kind) {
                case NDKKind.SubscriptionTier:
                    const tier = NDKSubscriptionTier.from(event);
                    if (tier.isValid) {
                        creators.add(event.pubkey);
                    }
                    break;

                default:
                    creatorsWithFreeContent.add(event.pubkey);
                    break;
            }
        }

        // return intersection of creators and creatorsWithFreeContent
        // creators.forEach(creator => {
        //     if (!creatorsWithFreeContent.has(creator)) {
        //         creators.delete(creator);
        //     }
        // });

        return Array.from(creators);
    });
</script>

<div class="flex flex-row gap-1 overflow-x-auto scrollable-content scrollable scrollbar-hide snap-x w-full -space-x-4">
    {#each $creators as pubkey (pubkey)}
        <UserProfile {pubkey} let:userProfile let:fetching let:authorUrl>
            {#if !fetching && userProfile}
                <a href={authorUrl} class="snap-center flex-none hover:pr-8 transition-all duration-300 group">
                    <div class="flex flex-row gap-2 items-center" data-tip={userProfile.displayName}>
                        <Avatar {userProfile} size="large" />
                    </div>
                </a>
            {/if}
        </UserProfile>
    {/each}
</div>
