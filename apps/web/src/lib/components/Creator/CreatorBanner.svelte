<script lang="ts">
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import UserProfile from "$components/User/UserProfile.svelte";
	import currentUser from '$stores/currentUser';
	import { userFollows } from '$stores/session';
	import { Avatar, ndk } from '@kind0/ui-common';
    import { Hexpubkey, NDKEvent, NDKKind, NDKList, NDKSubscriptionTier, NDKUser } from "@nostr-dev-kit/ndk";
	import { EventContent } from '@nostr-dev-kit/ndk-svelte-components';
	import { derived } from 'svelte/store';

    export let pubkey: Hexpubkey;
    export let tierList: NDKList | undefined = undefined;

    const userColor = '#' + pubkey.toString().slice(0, 6);

    const followedBy = $ndk.storeSubscribe({
        kinds:[3], "#p": [pubkey], authors: Array.from($userFollows)
    })

    let tiers: NDKEventStore<NDKSubscriptionTier> | undefined = undefined;

    if (tierList) {
        tiers = $ndk.storeSubscribe({
            kinds: [NDKKind.SubscriptionTier],
            authors: [pubkey],
            "ids": tierList.items.map(item => item[1])
        }, undefined, NDKSubscriptionTier);
    }

    const sortedFollowedBy = derived(followedBy, $followedBy => {
        const pubkeys = new Set<Hexpubkey>();

        for (const p of $followedBy) {
            pubkeys.add(pubkey);
        }

        pubkeys.delete(pubkey);
        if ($currentUser) pubkeys.delete($currentUser.pubkey!)

        return Array.from(pubkeys);
    });

    const subscribeEvents = $ndk.storeSubscribe({
        kinds: [NDKKind.Subscribe], "#p": [pubkey],
    });

    const supportedBy = derived(subscribeEvents, $subscribeEvents => {
        const pubkeys = new Set<Hexpubkey>();

        for (const event of $subscribeEvents) {
            pubkeys.add(pubkey);
        }

        pubkeys.delete(pubkey);
        if ($currentUser) pubkeys.delete($currentUser.pubkey!)

        return Array.from(pubkeys);
    });
</script>

<UserProfile {pubkey} let:userProfile let:authorUrl>
    {#if userProfile}
        <div class="rounded-lg p-4 break-inside flex-none w-[300px] h-fit mt-20">
            <a href={authorUrl} class="w-full border-radius relative flex flex-col justify-between p-4">
                {#if userProfile.banner}
                    <img class="absolute top-0 bg-gradie left-0 bottom-0 right-0 w-full h-full object-cover opacity-20" src={userProfile?.banner} alt="" />
                {:else}
                    <div class="absolute top-0 left-0 bottom-0 right-0 w-full h-full opacity-20"
                        style={`background: linear-gradient(180deg, ${userColor}aa 50%, ${userColor}00 100%);`} />
                {/if}
                <div class="w-full -translate-y-1/2 -mb-20">
                <AvatarWithName {userProfile} {authorUrl} {pubkey} avatarClass="w-40 h-40" class="text-2xl font-medium text-white !items-center flex-col" spacing="gap-4">
                </AvatarWithName>
                </div>

                <div class="text-sm w-fit {$$props.contentClass??""}">
                    <EventContent event={new NDKEvent()} content={userProfile?.about} ndk={$ndk} />
                </div>

                <div class="flex flex-row mt-4">
                    {#each $supportedBy.slice(0, 3) as pubkey (pubkey)}
                        <Avatar {pubkey} size="small" />
                    {/each}
                </div>

                <div class="flex flex-row mt-4">
                    {#each $sortedFollowedBy.slice(0, 3) as pubkey (pubkey)}
                        <Avatar {pubkey} size="small" />
                    {/each}
                </div>
            </a>
        </div>
    {/if}
</UserProfile>

<style lang="postcss">
    .container {
        @apply lg:w-1/3;
    }
</style>