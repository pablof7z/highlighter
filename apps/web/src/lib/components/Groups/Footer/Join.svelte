<script lang="ts">
	import { title } from '$stores/item-view';
    import { Hexpubkey, NDKEvent, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag, NDKZapConfirmation } from "@nostr-dev-kit/ndk";
    import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
	import { derived, Readable } from "svelte/store";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import { CaretDown, CaretRight, CrownSimple } from "phosphor-svelte";
	import { tierAmountToString } from "$lib/events/tiers";
	import currentUser from "$stores/currentUser";
	import PricingTiers from "./PricingTiers.svelte";
	import { createSubscriptionEvent } from "$components/Payment/subscription-event";
	import { ndk } from "$stores/ndk";
	import { calculateSatAmountFromAmount } from "$utils/currency";

    export let group: NDKSimpleGroup;
    export let metadata: Readable<NDKSimpleGroupMetadata>;
    export let members: Readable<NDKSimpleGroupMemberList>;
    export let admins: Readable<NDKSimpleGroupMemberList>;
    export let tiers: Readable<NDKSubscriptionTier[]>;
    export let openOnMount: boolean | undefined;

    export let onClose: (() => void) | undefined;

    const memberCount = derived([members, admins], ([$members, $admins]) => {
        if (!$members || !$admins) return;
        const allMembers = $members.memberSet;
        $admins.members.forEach(admin => allMembers.add(admin));
        return allMembers.size;
    })

    const nonAdminMembers = derived([members, admins], ([$members, $admins]) => {
        if (!$members || !$admins) return [];
        const allMembers = $members.memberSet;
        $admins.members.forEach(admin => allMembers.delete(admin));
        return Array.from(allMembers);
    })

    async function join() {
        group.requestToJoin($currentUser.pubkey)
    }

    async function subscribe() {
        if (!selectedTier) return;
        const a = selectedTier.amounts[0];
        if (!a) return;
        const { amount, term, currency } = a;
        if (!amount || !term || !currency) return;

        group.requestToJoin($currentUser.pubkey)
        
        const startEvent = await createSubscriptionEvent($ndk, amount.toString(), currency, term, selectedTier.author, selectedTier);

        const zapTags: NDKTag[] = [
            ...startEvent.referenceTags()
        ];

        const satAmount = await calculateSatAmountFromAmount(a);

        const res = await $ndk.zap(selectedTier.author, Math.floor(satAmount * 1000), "Membership to NIP-29 group "+$metadata.name, zapTags);
        res.on("complete", async (info: NDKZapConfirmation | Error) => {
            if (info instanceof Error) {
                console.error(info);
                return;
            }
            
            startEvent.publish();

            if (info instanceof NDKEvent) {
                info.publish();
            }
        });
    }

    let selectedTier: NDKSubscriptionTier | undefined;

    let mainView: string;
    let open: (view?: string | false) => void;
</script>

<Footer.Shell
    {openOnMount}
    bind:open
    hideCollapsedView={mainView !== 'subscribe'}
    on:collapse={() => { if (onClose) onClose() }}
    bind:mainView
    maxHeight="100vh"
>
    {#if mainView === "subscribe"}
        <div class="flex flex-row items-center gap-2">
            {#if $metadata.picture}
                <img src={$metadata.picture} class="rounded-full w-8 h-8 object-cover" />
            {/if}
        
            <b>{$metadata.name}</b>
        </div>
    {:else}
        <Button variant="accent" class="w-full" on:click={() => open()}>
            View Info & Join
        </Button>
    {/if}

    <div class="flex flex-col gap-3 items-center justify-stretch w-full" slot="main">
        {#if mainView === 'subscribe'}
            <PricingTiers
                {tiers}
                bind:selectedTier
            />

            <Button
                variant="accent"
                class="w-full justify-between"
                on:click={subscribe}
                disabled={!selectedTier}
            >
                {#if selectedTier}
                    <div>
                        Join for
                        {tierAmountToString(selectedTier.amounts[0])}
                    </div>
                {:else}
                    Select a membership level
                {/if}
            </Button>
        {:else}
            <section class="w-full flex flex-col gap-2 items-center">
                {#if $metadata.picture}
                    <img src={$metadata.picture} class="rounded-full w-24 h-24 object-cover" />
                    <img src={$metadata.picture} class="object-cover -z-10 absolute top-0 left-0 w-full h-full opacity-10" />
                {/if}
        
                <h1>{$metadata.name}</h1>
        
                {#if $metadata.about}
                    <div class="text-left text-muted-foreground">
                        {$metadata.about}
                    </div>
                {/if}
            </section>

            {#if $metadata.access === "closed" && $tiers.length > 0}
                <Button
                    variant="accent"
                    class="w-full justify-between"
                    on:click={() => open('subscribe')}
                >
                    <div>
                        Join &mdash;
                        Starting at
                        {tierAmountToString($tiers[0].amounts[0])}
                    </div>
                    <CaretDown size={16} class="ml-1" />
                </Button>
            {:else}
                <Button
                    variant="accent"
                    class="w-full justify-between"
                    on:click={join}
                >
                    Join
                </Button>
            {/if}
        {/if}

        <section class="w-full flex flex-col gap-2">
            <div class="flex flex-row justify-between w-full text-sm text-muted-foreground">
                <div>Members</div>

                <span>
                    {$memberCount}
                </span>
            </div>

            <div class="flex flex-col rounded w-full bg-background/50">
                {#if $admins}
                    {#each $admins.members as admin}
                        <div class="flex flex-row justify-between w-full items-center text-sm font-semibold p-2 px-4">
                            <AvatarWithName pubkey={admin} avatarSize="small" />

                            <Badge variant="secondary" class="text-muted-foreground">
                                <CrownSimple size={12} class="text-gold mr-1.5" weight="fill" />
                                Admin
                            </Badge>
                        </div>
                    {/each}
                {/if}

                {#each $nonAdminMembers as pubkey}
                    <div class="flex flex-row justify-between w-full items-center text-sm font-semibold p-2 px-4">
                        <AvatarWithName {pubkey} avatarSize="small" />
                    </div>
                {/each}
            </div>
        </section>
    </div>
</Footer.Shell>

<style lang="postcss">
    section {
        @apply w-full flex flex-col gap-2
    }
</style>