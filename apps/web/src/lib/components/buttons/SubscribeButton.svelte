<script lang="ts">
	import type { NDKSubscriptionTier, NDKUser } from "@nostr-dev-kit/ndk";
	import CaretRight from "phosphor-svelte/lib/CaretRight";
    import currentUser from "$stores/currentUser";
    import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { openModal } from '$utils/modal';
	import SignupModal from "$modals/SignupModal.svelte";
	import { getUserSubscriptionTiersStore, getUserSupporters } from "$stores/user-view";
	import UserProfile from "$components/User/UserProfile.svelte";
	import type { Readable } from "svelte/store";
	import { Star, Ticket } from "phosphor-svelte";
	import type { UserProfileType } from "../../../app";
	import Button from "$components/ui/button/button.svelte";

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

    $: if (userProfile) hasLNPayments = !!(userProfile.lud06 || userProfile.lud16);
</script>

{#if user && user.pubkey !== $currentUser?.pubkey}
    <UserProfile bind:authorUrl bind:userProfile {user} />

    {#if !currentUserSubscriberTier}
        {#if hasLNPayments !== false}
            <Button on:click={openSupportModal}>
                <span class="hidden lg:inline">
                    {#if $tiers && $tiers.length > 0}
                        Subscribe
                    {:else}
                        Support
                    {/if}
                </span>
            </Button>
        {/if}
    {/if}
{/if}