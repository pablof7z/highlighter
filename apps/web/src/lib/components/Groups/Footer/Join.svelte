<script lang="ts">
    import { Hexpubkey, NDKEvent, NDKKind, NDKPaymentConfirmation, NDKSimpleGroup, NDKSubscriptionTier, NDKTag, NDKZapSplit } from "@nostr-dev-kit/ndk";
    import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
	import { derived, Readable } from "svelte/store";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import Badge from "$components/ui/badge/badge.svelte";
	import { CaretDown, CaretRight, CheckCircle, CrownSimple } from "phosphor-svelte";
	import { tierAmountToString } from "$lib/events/tiers";
	import currentUser from "$stores/currentUser";
	import PricingTiers from "./PricingTiers.svelte";
	import { createSubscriptionEvent } from "$components/Payment/subscription-event";
	import { ndk } from "$stores/ndk";
	import { calculateSatAmountFromAmount } from "$utils/currency";
	import { onDestroy, getContext } from 'svelte';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import * as Groups from "$components/Groups"

    export let group: Readable<Groups.GroupData>;
    export let openOnMount: boolean | undefined;
    export let isMember: Readable<boolean>;

    export let onClose: (() => void) | undefined;

    let myJoinRequests: NDKEventStore<NDKEvent> | undefined;
    let joinRequested = false;

    $: if ($currentUser && $isMember === false && !myJoinRequests) {
        myJoinRequests = $ndk.storeSubscribe({
            kinds: [NDKKind.GroupAdminRequestJoin],
            "#h": [$group.id],
            authors: [$currentUser.pubkey]
        }, { relaySet: $group.relaySet });
    }
    $: joinRequested = !!($myJoinRequests && $myJoinRequests.length > 0);

    onDestroy(() => {
        myJoinRequests?.unsubscribe();
    })

    const memberCount = derived(group, $group => {
        if (!$group.members || !$group.admins) return;
        const allMembers = $group.members.memberSet;
        $group.admins.members.forEach(admin => allMembers.add(admin));
        return allMembers.size;
    })

    const nonAdminMembers = derived(group, $group => {
        if (!$group.members || !$group.admins) return [];
        const allMembers = $group.members.memberSet;
        $group.admins.members.forEach(admin => allMembers.delete(admin));
        return Array.from(allMembers);
    })

    async function join() {
        if (!$currentUser) return;

        const g = new NDKSimpleGroup($ndk, $group.relaySet, $group.id);
        g.requestToJoin($currentUser.pubkey)
    }

    async function subscribe() {
        if (!$currentUser) return;
        if (!selectedTier) return;
        const a = selectedTier.amounts[0];
        if (!a) return;
        const { amount, term, currency } = a;
        if (!amount || !term || !currency) return;

        // group.requestToJoin($currentUser.pubkey)
        
        const startEvent = await createSubscriptionEvent($ndk, amount.toString(), currency, term, selectedTier.author, selectedTier);

        const zapTags: NDKTag[] = [
            ...startEvent.referenceTags()
        ];

        const satAmount = await calculateSatAmountFromAmount(a);

        const res = await $ndk.zap(
            selectedTier.author,
            Math.floor(satAmount * 1000),
            {
                comment: "Membership in community "+$group.metadata.name,
                tags: zapTags
        });
        res.on("complete", async (results: Map<NDKZapSplit, NDKPaymentConfirmation | Error | undefined>) => {
            const info = results.values().next().value;
            if (info instanceof Error) {
                console.error(info);
                return;
            }
            
            startEvent.publish();
            startEvent.publish($group.relaySet);
        });
        await res.zap();
    }

    let selectedTier: NDKSubscriptionTier | undefined;

    let mainView: string;
    let open: (view?: string | false) => void;
</script>

<Footer.Shell
    bind:open
    hideCollapsedView={mainView !== 'subscribe'}
    on:collapse={() => { if (onClose) onClose() }}
    bind:mainView
    maxHeight="100vh"
    class="max-w-[var(--content-focused-width)] mx-auto"
>
    {#if joinRequested}
        <Button variant="accent" class="w-full" on:click={() => open('main')}>
            <CheckCircle size={16} class="mr-1" />
            Requested to Join
        </Button>
    {:else}
        {#if mainView === "subscribe"}
            <div class="flex flex-row items-center gap-2">
                <Groups.Avatar group={$group} class="rounded-full w-8 h-8 object-cover" />
                <b><Groups.Name group={$group} /></b>
            </div>
        {:else}
            <Button variant="accent" class="w-full" on:click={() => open('main')}>
                View Info & Join
            </Button>
        {/if}
    {/if}

    <div class="flex flex-col gap-3 items-center justify-stretch w-full" slot="main">
        {#if mainView === 'subscribe' && $group.tiers}
            <PricingTiers
                tiers={$group.tiers}
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
                {#if $group.picture}
                    <img src={$group.picture} class="rounded-full w-24 h-24 object-cover" />
                    <img src={$group.picture} class="object-cover -z-10 absolute top-0 left-0 w-full h-full opacity-10" />
                {/if}
        
                <h1>{$group.name}</h1>
        
                {#if $group.about}
                    <div class="text-left text-muted-foreground">
                        {$group.about}
                    </div>
                {/if}
            </section>

            <div class="flex flex-row w-full gap-2">
                {#if $group.access === "closed" && $group.tiers}
                    <Button
                        variant="accent"
                        class="w-full justify-between"
                        on:click={() => open('subscribe')}
                    >
                        <div>
                            Join &mdash;
                            Starting at
                            {tierAmountToString($group.tiers[0].amounts[0])}
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
                <Button variant="ghost" on:click={() => open(false)}>
                    Close
                </Button>
            </div>
        {/if}

        <section class="w-full flex flex-col gap-2">
            <div class="flex flex-row justify-between w-full text-sm text-muted-foreground">
                <div>Members</div>

                <span>
                    {$memberCount}
                </span>
            </div>

            <div class="flex flex-col rounded w-full bg-background/50">
                {#if $group.admins}
                    {#each $group.admins.members as admin}
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