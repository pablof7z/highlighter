<script lang="ts">
	import type { NDKSubscriptionTier, NDKUser } from "@nostr-dev-kit/ndk";
	import CaretRight from "phosphor-svelte/lib/CaretRight";
    import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { openModal } from "svelte-modals";
	import SignupModal from "$modals/SignupModal.svelte";
    import { user as currentUser } from "@kind0/ui-common";
	import { getUserSubscriptionTiersStore, getUserSupporters } from "$stores/user-view";
	import UserProfile from "$components/User/UserProfile.svelte";
	import type { Readable } from "svelte/store";
	import { X } from "phosphor-svelte";
	import type { UserProfileType } from "../../../app";

    export let user: NDKUser;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    export let userProfile: UserProfileType | undefined = undefined;

    tiers ??= getUserSubscriptionTiersStore();

    let currentUserSubscriberTier: string | undefined;
    const supporters = getUserSupporters();
    // $: currentUserSubscriberTier = ($currentUser && $supporters[$currentUser.pubkey]) || undefined;

    function openSupportModal() {
        if ($currentUser) {
            openModal(BecomeSupporterModal, { user });
        } else {
            openModal(SignupModal);
        }
    }

    let authorUrl: string;
    let hasLNPayments: boolean | undefined;

    $: if (userProfile && (!userProfile.lud06 && !userProfile.lud16)) {
        hasLNPayments = false;
    }
</script>

<UserProfile bind:authorUrl {user} />

{#if !currentUserSubscriberTier}
    {#if hasLNPayments === false}
        <div class="text-xs">
            <X class="w-4 h-4 inline text-red-800" />
            No payments enabled for {userProfile.name}
        </div>
    {:else}
        <button
            on:click={openSupportModal}
            class="
                button flex flex-row items-center !gap-0
                whitespace-nowrap button-primary text-base
                max-sm:w-full max-sm:!rounded-md
            "
        >
            {#if $tiers.length > 0}
                Go Backstage
            {:else}
                Support
            {/if}
            <CaretRight class="w-5 h-5 inline" />
        </button>
    {/if}
{:else if $tiers.length > 0}
    <a href="{authorUrl}/backstage"
        on:click={openSupportModal}
        class="
            button flex flex-row items-center !gap-0
            whitespace-nowrap button-primary text-base
        "
    >
        Go Backstage
        <CaretRight class="w-5 h-5 inline" />
    </a>
{:else}
    You are a supporter!
{/if}
