<!--
    This is a component that renders a list of current and past supporters.

    It's intended to be displayed for the creator.
-->
<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { getUserSupportPlansStore, getUserSupporters, userTiers } from "$stores/user-view";
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
	import type { NDKUser, Hexpubkey, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { derived, type Readable } from "svelte/store";
	import { slide } from "svelte/transition";
    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    let supporters: Readable<Record<Hexpubkey, string|undefined>> | undefined = undefined;
    let tierNames: Record<string, string> = {};

    onMount(() => {
        supporters = getUserSupporters();
    });

    const tiers = getUserSupportPlansStore();

    $: for (const tier of $tiers) {
        const dTag = tier.tagValue("d");
        if (!dTag) {
            console.warn("No d tag for tier", tier.rawEvent());
            continue;
        } else {
            tierNames[dTag] = tier.title;
        }
    }

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
                        {tierNames[tier]??tier}
                    </span>
                </div>

            </UserProfile>
        {/each}
    </div>
{/if}
