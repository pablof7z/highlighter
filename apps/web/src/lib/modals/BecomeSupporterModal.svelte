<script lang="ts">
	import ModalShell from '$components/ModalShell.svelte';
    import TierHeader from "$components/TierHeader.svelte";
    import { user as loggedInUser } from '@kind0/ui-common';
    import { userSuperFollows } from '$stores/session';
    import Tier from "$components/Tier.svelte";
	import type { NDKArticle, NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";
	import type { Readable } from "svelte/motion";
	import { derived } from "svelte/store";
	import { termToShort, type Term } from "$utils/term";
	import { slide } from 'svelte/transition';
	import { Name } from '@kind0/ui-common';
	import WalletConnect from '$components/Payment/WalletConnect.svelte';
	import Subscribe from '$components/Payment/Subscribe.svelte';
	import { closeModal } from 'svelte-modals';
	import { onMount } from 'svelte';
	import ThankYou from '$components/Payment/ThankYou.svelte';
	import { isNwcAvailable } from '$utils/nwc';
	import { currencyFormat } from '$utils/currency';
	import type { UserProfileType } from '../../app';
	import EmptyTierForm from '$components/EmptyTierForm.svelte';
	import { getUserSupportPlansStore } from '$stores/user-view';

    export let user: NDKUser;
    export let tiers: Readable<NDKArticle[]> | undefined = undefined;

    if (!tiers) {
        tiers = getUserSupportPlansStore();
    }

    console.log("tiers", $tiers);

    let bitcoin = false;
    let paid = false;
    let nwcMode: any;
    let userHasWalletConnected = false;
    let nwcUrl: string;
    let userProfile: UserProfileType;

    let selected: NDKEvent | undefined;
    let selectedTerm: Term = "monthly";
    let selectedAmount: number | undefined;
    let selectedCurrency: string | undefined = 'USD'

    onMount(() => {
        userHasWalletConnected = isNwcAvailable();
    });

    function onWalletConnected() {
        userHasWalletConnected = true;
    }

    const availableTerms = derived(tiers, ($tiers) => {
        const terms = new Set<Term>();
        $tiers.forEach((tier: NDKEvent) => {
            const amountTags = tier.getMatchingTags("amount")
            for (const amountTag of amountTags) {
                if (amountTag[3]) terms.add(amountTag[3] as Term);
            }
        });

        if (terms.size === 0) {
            terms.add("weekly");
            terms.add("monthly");
            terms.add("yearly");
        }

        return Array.from(terms);
    });

    const sortedTiers = derived(tiers, $tiers => {
        const t = $tiers.sort((a, b) => {
            const aAmount = a.getMatchingTags("amount").find((tag) => tag[3] === selectedTerm)![1];
            const bAmount = b.getMatchingTags("amount").find((tag) => tag[3] === selectedTerm)![1];
            return Number(aAmount) - Number(bAmount);
        });

        if (!selected && t[0]) selectTier(t[0]);

        return t;
    });

    function selectTier(tier: NDKEvent) {
        selected = tier;
        const t = tier.getMatchingTags("amount").find((tag) => tag[3] === selectedTerm)!;
        selectedAmount = parseFloat(t[1]);
        selectedCurrency = t[2]!;
    }

    function selectTerm(term: Term) {
        selectedTerm = term;
        if (selected) selectTier(selected);
    }

    function backClicked() {
        if (bitcoin) {
            if (nwcMode) {
                nwcMode = undefined;
            } else {
                bitcoin = false;
            }
        }
    }

    async function follow() {
        closeModal();

        if ($userSuperFollows.has(user.pubkey)) return;

        $loggedInUser.follow(user, undefined, 17001);
    }

    async function onPaid() {
        paid = true;
        if ($userSuperFollows.has(user.pubkey)) return;
        $loggedInUser.follow(user, undefined, 17001);
    }
</script>

<ModalShell color="glassy">
    <TierHeader
        {user}
        bind:userProfile
        showBackArrow={bitcoin}
        on:back={backClicked}
    />

    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div on:click|preventDefault|stopPropagation={() => {}} class="w-full relative">
        {#if !paid}
            {#if !bitcoin}
                <div class="flex flex-col flex-nowrap gap-6 items-center" transition:slide>
                    {#if $availableTerms.length > 1}
                        <div class="justify-center items-center inline-flex">
                            {#each $availableTerms as term}
                                <button
                                    class="px-2.5 py-1 rounded-full justify-center items-center flex"
                                    class:bg-zinc-100={term === selectedTerm}
                                    on:click={() => selectTerm(term)}
                                >
                                    <div class="text-center text-black text-[15px] font-medium">{term}</div>
                                </button>
                            {/each}
                        </div>
                    {/if}

                    <div class="flex flex-col md:flex-row gap-4">
                        {#if $sortedTiers.length === 0}
                            <EmptyTierForm
                                bind:selectedAmount
                                bind:currency={selectedCurrency}
                                {userProfile}
                                term={selectedTerm}
                            />
                        {/if}
                        {#each $sortedTiers as tier}
                            <Tier
                                {tier}
                                on:click={() => selectTier(tier)}
                                selected={selected === tier}
                                term={selectedTerm}
                            />
                        {/each}
                    </div>

                    <div
                        class="justify-center items-start gap-5 inline-flex"
                    >
                        {#if selectedAmount && selectedCurrency}
                            <button
                                class="button button-primary"
                                class:opacity-0={selectedCurrency === "msat"}
                                disabled={!selectedAmount || selectedCurrency === "msat"}
                            >
                                Support for {currencyFormat(selectedCurrency, selectedAmount)}/{termToShort(selectedTerm)}
                            </button>
                        {/if}

                        <button
                            class="button button-primary"
                            on:click={() => bitcoin = true}
                            disabled={!selectedAmount}
                        >
                            Pay in Bitcoin
                        </button>
                    </div>

                    <button
                        class="text-center text-black text-opacity-50 text-sm font-normal leading-5"
                        on:click={follow}
                    >No thanks, basic follow for free</button>
                </div>
            {:else}
                <div class="flex flex-col flex-nowrap gap-6 items-center" transition:slide>
                    {#if !userHasWalletConnected}
                        <div class="text-center text-black text-base font-normal leading-normal">
                            Connect a lightning wallet to subscribe to
                            <Name {user} />'s
                            content.
                        </div>

                        <WalletConnect bind:mode={nwcMode} bind:nwcUrl on:connected={onWalletConnected} />
                    {:else if selectedAmount && selectedCurrency}
                        <Subscribe
                            amount={selectedAmount.toString()}
                            currency={selectedCurrency}
                            term={selectedTerm}
                            plan={selected}
                            supportedUser={user}
                            on:paid={onPaid}
                            on:disconnectWallet={() => userHasWalletConnected = false}
                        />
                    {/if}
                </div>
            {/if}
        {:else}
            <ThankYou {user} />
        {/if}
    </div>
</ModalShell>

<!-- <style lang="postcss">
    a {
        @apply px-4 py-3 rounded-xl justify-start items-start gap-2 inline-flex;
        @apply text-black text-sm font-semibold leading-5;
        @apply flex-col justify-start items-center gap-2 inline-flex;

        & > span {
            @apply w-8 h-8 pl-1 pr-0.5 pt-0.5 pb-1 justify-center items-center inline-flex self-center;
        }

        &:hover {
            @apply hover:bg-zinc-100;
        }
    }
</style> -->