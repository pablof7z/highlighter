<!--
    This is a component that renders a list of current and past supporters.

    It's intended to be displayed for the creator.
-->
<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { getUserSupporters } from "$stores/user-view";
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
	import type { NDKUser, Hexpubkey, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import type { Readable } from "svelte/store";
	import { slide } from "svelte/transition";
    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    let supporters: Readable<Record<Hexpubkey, string|undefined>> | undefined = undefined;

    onMount(() => {
        supporters = getUserSupporters();
    })

    const payments = $ndk.storeSubscribe(
        { kinds: [7003], "#P": [$user?.pubkey] }
    )
</script>

{#if $supporters}
    <div class="flex flex-col divide-y divide-base-300 {$$props.class??""}">
        {#each Object.entries($supporters) as [pubkey, tier]}
            <UserProfile {pubkey} let:userProfile let:fetching>
                <div class="flex flex-row items-center justify-between py-2">
                    <div class="flex flex-row items-center gap-2" transition:slide>
                    <Avatar {pubkey} {userProfile} {fetching} class="w-10 h-10 border-2 border-black" />

                    <Name {pubkey} {userProfile} {fetching} class="font-semibold text-white" />
                </div>

                <span class="bafge badge-neutral text-white text-opacity-60 text-sm font-normal leading-6">
                    {tier}
                </span>
                </div>

            </UserProfile>
        {/each}
    </div>
{/if}

{#if $payments}
    <div class="flex flex-col divide-y divide-base-300 {$$props.class??""}">
        {#each $payments as payment}
            <pre>{JSON.stringify(payment.rawEvent(), null, 2)}</pre>
        {/each}
    </div>
{/if}