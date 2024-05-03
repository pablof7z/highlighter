<script lang="ts">
	import CreatorBanner from "$components/Creator/CreatorBanner.svelte";
	import { blacklistedPubkeys, featuredCreatorPubkeys } from "$utils/const";
	import { ndk } from "@kind0/ui-common";
	import { type Hexpubkey, NDKKind, NDKList, NDKSubscriptionStart } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";

    const events = $ndk.storeSubscribe([
        {kinds: [NDKKind.Subscribe], limit: 100},
        {kinds: [NDKKind.TierList], limit: 100},
    ], { closeOnEose: true });

    onDestroy(() => {
        events.unsubscribe();
    });

    const subscriptionTierList = new Map<Hexpubkey, NDKList>();

    const creators = derived(events, $events => {
        const creators = new Set<Hexpubkey>();
        const creatorsWithFreeContent = new Set<Hexpubkey>();

        for (const event of $events) {
            if (blacklistedPubkeys.includes(event.pubkey)) continue;

            switch (event.kind) {
                case NDKKind.Subscribe:
                    const subscription = NDKSubscriptionStart.from(event);
                    if (subscription.isValid && subscription.recipient) {
                        creators.add(subscription.recipient.pubkey);
                    }
                    break;
                case NDKKind.TierList:
                    const tierList = NDKList.from(event);
                    if (tierList.isValid && tierList.items.length > 0) {
                        const current = subscriptionTierList.get(tierList.pubkey);
                        if (!current || current.created_at! < tierList.created_at!) {
                            subscriptionTierList.set(tierList.pubkey, tierList);
                        }
                        creators.add(tierList.pubkey);
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

        // return Array.from(creatorsWithFreeContent);
        return Array.from(creators)
            .filter(creator => subscriptionTierList.has(creator))
    });

    const featuredCreators = derived(creators, $creators => {
        const ret: Hexpubkey[] = [];

        for (const creator of $creators) {
            if (featuredCreatorPubkeys.includes(creator)) {
                ret.push(creator);
            }
        }

        return ret;
    })
</script>

<svelte:head>
    <title>Discover Creators on Nostr</title>
</svelte:head>

<h1 class="text-white">
    Featured Creators
</h1>

{#each $featuredCreators as pubkey (pubkey)}
    <CreatorBanner {pubkey} tierList={subscriptionTierList.get(pubkey)} />
{/each}

<div class="masonry sm:masonry-sm md:masonry-md">
    {#each $creators.slice(0, 10) as creator (creator)}
        <CreatorBanner
            pubkey={creator}
            tierList={subscriptionTierList.get(creator)}
            contentClass="max-w-[300px]"
        />
    {/each}
</div>