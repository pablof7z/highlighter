<script lang="ts">
	import type { NDKSubscriptionTier, NDKUser } from "@nostr-dev-kit/ndk";
	import CaretRight from "phosphor-svelte/lib/CaretRight";
    import currentUser from "$stores/currentUser";
    import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { openModal } from "svelte-modals";
	import SignupModal from "$modals/SignupModal.svelte";
	import { getUserSubscriptionTiersStore, getUserSupporters } from "$stores/user-view";
	import UserProfile from "$components/User/UserProfile.svelte";
	import type { Readable } from "svelte/store";
	import { X } from "phosphor-svelte";
	import type { UserProfileType } from "../../../app";

    export let user: NDKUser;
    export let tiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    export let userProfile: UserProfileType | undefined = undefined;

    tiers ??= getUserSubscriptionTiersStore();

    let currentUserSubscriberTier: string | true | undefined;
    const supporters = getUserSupporters();
    $: {
        if (supporters && $supporters) {
            currentUserSubscriberTier = !!($currentUser && $supporters[$currentUser.pubkey]) || undefined;
        }
    }

    function openSupportModal() {
        if ($currentUser) {
            openModal(BecomeSupporterModal, { user });
        } else {
            openModal(SignupModal);
        }
    }

    let authorUrl: string;
    let hasLNPayments: boolean | undefined = !!(userProfile?.lud06 || userProfile?.lud16);

    $: hasLNPayments = !!(userProfile?.lud06 || userProfile?.lud16);
</script>

{#if user && user.pubkey !== $currentUser?.pubkey}
    <UserProfile bind:authorUrl {user} />

    {#if !currentUserSubscriberTier}
        {#if hasLNPayments === false}
            <div class="text-xs">
                <X class="w-4 h-4 inline text-red-800" />
                No payments enabled for {userProfile?.name??"this user"}
            </div>
        {:else}
            <button
                on:click={openSupportModal}
                class="
                    button flex flex-row items-center !gap-0
                    whitespace-nowrap text-base
                    max-sm:w-full max-sm:!rounded-md
                    {$$props.buttonClass??""}
                "
            >
                {#if $tiers && $tiers.length > 0}
                    Go Backstage
                {:else}
                    Support
                {/if}
                <CaretRight class="w-5 h-5 inline" />
            </button>
        {/if}
    {/if}
{/if}