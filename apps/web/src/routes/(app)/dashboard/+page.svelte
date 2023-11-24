<script lang="ts">
	import Timeline from '$components/Events/Timeline.svelte';
	import NewTier from '$components/Forms/NewTier.svelte';
	import PageTitle from "$components/Page/PageTitle.svelte";
	import NewItemModal from "$modals/NewItemModal.svelte";
	import { getUserSupporters, startUserView } from '$stores/user-view';
	import { Avatar, Name, user } from "@kind0/ui-common";
	import type { Hexpubkey, NDKEvent } from '@nostr-dev-kit/ndk';
	import { onMount } from 'svelte';
	import { openModal } from "svelte-modals";
	import type { Readable } from 'svelte/motion';

    let supporters: Readable<NDKEvent[]> | undefined = undefined;
    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    $: if (supporters && $supporters) {
        for (const supportEvent of $supporters) {
            supportingPubkeys.add(supportEvent.pubkey);
        }
        supportingPubkeys = supportingPubkeys;
    }

    onMount(() => {
        startUserView($user);
        supporters = getUserSupporters();
    })

    function publish() {
        openModal(NewItemModal);
    }
</script>

<div class="flex flex-col gap-10 mx-auto max-w-prose">
    <PageTitle title="Creator Dashboard">
        <div class="flex flex-row gap-2">
            <!-- <button on:click={preview} class="button button-primary">Preview</button>
            <button on:click={preview} class="button button-primary">Save Draft</button> -->
            <button on:click={publish} class="button px-10">Publish</button>
        </div>
    </PageTitle>

    <div class="flex flex-row items-center gap-4">
        <Avatar user={$user} class="w-32 h-32" />

        <div class="flex flex-col gap-2">
            <Name user={$user} class="text-xl font-semibold text-white" />
            {#if supportingPubkeys}
                <div class="text-white text-opacity-60 text-sm font-normal leading-6">
                    0
                    subscribers  ·  {supportingPubkeys?.size} paying supporters
                </div>
            {/if}
        </div>

        <div class="ml-auto">
            {#await $user.fetchProfile() then profile}
                <a href="/{profile.nip05}" class="button px-6">View Profile</a>
            {/await}
        </div>
    </div>

    <Timeline user={$user} />
</div>