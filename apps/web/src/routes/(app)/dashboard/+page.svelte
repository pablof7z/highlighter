<script lang="ts">
	import CreatorFeed from '$components/Feed/CreatorFeed.svelte';
	import Timeline from '$components/Events/Timeline.svelte';
	import PageTitle from "$components/Page/PageTitle.svelte";
	import DashboardStats from '$components/dashboard/DashboardStats.svelte';
	import NewItemModal from "$modals/NewItemModal.svelte";
	import { getUserContent, getUserSupporters, startUserView } from '$stores/user-view';
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
	import type { Hexpubkey, NDKEvent } from '@nostr-dev-kit/ndk';
	import { onMount } from 'svelte';
	import { openModal } from "svelte-modals";
	import type { Readable } from 'svelte/motion';
	import UserProfile from '$components/User/UserProfile.svelte';

    let supporters: Readable<NDKEvent[]> | undefined = undefined;
    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    const subscribers = $ndk.storeSubscribe(
        { kinds: [17001], "#p": [$user.pubkey] }
    )

    $: if (supporters && $supporters) {
        for (const supportEvent of $supporters) {
            supportingPubkeys.add(supportEvent.pubkey);
        }
        supportingPubkeys = supportingPubkeys;
    }

    let mounted = false;

    onMount(() => {
        startUserView($user);
        supporters = getUserSupporters();
        mounted = true;
    })

    function publish() {
        openModal(NewItemModal);
    }

    let profileLink = `/${$user.npub}`;
    $user.fetchProfile().then(profile => {
        if (profile && profile.nip05)
            profileLink = `/${profile.nip05}`;
    });
</script>

{#if mounted}
<div class="flex flex-col gap-10 mx-auto max-w-prose">
    <PageTitle title="Creator Dashboard">
        <div class="flex flex-row gap-2">
            <!-- <button on:click={preview} class="button button-primary">Preview</button>
            <button on:click={preview} class="button button-primary">Save Draft</button> -->
            <button on:click={publish} class="button px-10">Publish</button>
        </div>
    </PageTitle>

    <UserProfile user={$user} let:userProfile let:authorUrl let:fetching>
        <a href={authorUrl} class="flex flex-row items-center gap-4 text-left">
            <Avatar user={$user} {userProfile} {fetching} class="w-32 h-32" />

            <div class="flex flex-col gap-2">
                <Name user={$user} {userProfile} {fetching} class="text-xl font-semibold text-white" />
                {#if supportingPubkeys}
                    <div class="text-white text-opacity-60 text-sm font-normal leading-6">
                        {$subscribers.length}
                        subscribers  ·  {supportingPubkeys?.size} paying supporters
                    </div>
                {/if}
            </div>
        </a>
    </UserProfile>

    <DashboardStats />

    <CreatorFeed content={getUserContent()} />
</div>
{/if}