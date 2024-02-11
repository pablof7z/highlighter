<script lang="ts">
	import ModalShell from '$components/ModalShell.svelte';
    import { user as loggedInUser } from '@kind0/ui-common';
    import { userSuperFollows } from '$stores/session';
    import Tier from "$components/Tier.svelte";
	import type { NDKIntervalFrequency, NDKSubscriptionTier, NDKUser } from "@nostr-dev-kit/ndk";
	import type { Readable } from "svelte/motion";
	import { derived } from "svelte/store";
	import { termToShort } from "$utils/term";
	import { slide } from 'svelte/transition';
	import { Name } from '@kind0/ui-common';
	import WalletConnect from '$components/Payment/WalletConnect.svelte';
	import Subscribe from '$components/Payment/Subscribe.svelte';
	import { closeModal } from 'svelte-modals';
	import { onMount } from 'svelte';
	import ThankYou from '$components/Payment/ThankYou.svelte';
	import { isNwcAvailable } from '$utils/nwc';
	import { currencyCode, currencyFormat } from '$utils/currency';
	import type { UserProfileType } from '../../app';
	import EmptyTierForm from '$components/EmptyTierForm.svelte';
	import { getUserSubscriptionTiersStore } from '$stores/user-view';
    import createDebug from 'debug';
    import {requestProvider} from 'webln';

    export let user: NDKUser;

    const d = createDebug('HL:become-supporter-modal');

    let tiers: Readable<NDKSubscriptionTier[]> | undefined = getUserSubscriptionTiersStore();

    $: d("tiers", $tiers);

    let bitcoin = false;
    let paid = false;
    let nwcMode: any;
    let userHasWalletConnected = false;
    let nwcUrl: string;
    let userProfile: UserProfileType;

    let selected: NDKSubscriptionTier | undefined;
    let selectedTerm: NDKIntervalFrequency = "monthly";
    let selectedAmount: number | undefined;
    let selectedCurrency: string | undefined;

    let hasTiers: boolean;

    $: hasTiers = $tiers.length > 0;

    let isWeblnAvailable = false;

    onMount(() => {
        userHasWalletConnected = isNwcAvailable();
        requestProvider().then((provider) => {
            isWeblnAvailable = !!provider;
        });
    });

    function onWalletConnected() {
        userHasWalletConnected = true;
    }

    const availableCurrencies = derived(tiers, ($tiers) => {
        const currencies = new Set<string>();
        $tiers.forEach((tier: NDKSubscriptionTier) => {
            for (const amount of tier.amounts) {
                currencies.add(amount.currency);
            }
        });

        if (!selectedCurrency) {
            if (currencies.has('msat')) {
                selectedCurrency = 'msat';
            } else {
                selectedCurrency = Array.from(currencies)[0];
            }
        }

        return Array.from(currencies);
    });

    const sortedTiers = derived(tiers, $tiers => {
        const t = $tiers
            .sort((a, b) => {
                const aAmount = a.amounts.find((amount) => amount.currency === selectedCurrency);
                const bAmount = b.amounts.find((amount) => amount.currency === selectedCurrency);

                if (aAmount && bAmount) return aAmount.amount - bAmount.amount;

                return 0;
            });

        if (!selected && t[0]) {
            selected = t[0];
            const amount = t[0].amounts[0];
            selectedAmount = amount.amount;
            selectedCurrency = amount.currency;
            selectedTerm = amount.term;
        }

        return t;
    });

    async function onPaid() {
        paid = true;
        if ($userSuperFollows.has(user.pubkey)) return;
        $loggedInUser.follow(user, undefined, 17001);
    }
</script>

<ModalShell color="glassy" class="max-sm:w-full">
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div on:click|preventDefault|stopPropagation={() => {}} class="w-full relative">
        {#if !paid}
            {#if !bitcoin}
                <div class="flex flex-col flex-nowrap gap-6 items-stretch sm:items-center" transition:slide>
                    {#if $availableCurrencies.length > 0}
                        <div class="w-full self-end">
                            <select class="select !bg-white/10" bind:value={selectedCurrency}>
                                {#each $availableCurrencies as currency}
                                    <option value={currency}>
                                        {currencyCode(currency)}
                                    </option>
                                {/each}
                            </select>
                        </div>
                    {/if}

                    <div class="
                        flex flex-col md:flex-row gap-4 items-start overflow-y-auto max-sm:max-h-[50vh]
                        sm:max-w-[60vw] sm:overflow-x-auto overscroll-contain max-sm:snap-y sm:snap-x
                        snap-mandatory
                    ">
                        {#if $sortedTiers.length === 0}
                            <EmptyTierForm
                                bind:selectedAmount
                                bind:currency={selectedCurrency}
                                {userProfile}
                                term={selectedTerm}
                            />
                        {/if}
                        {#each $sortedTiers as tier (tier.id)}
                            {#if tier.amounts.some(amount => amount.currency === selectedCurrency)}
                                <Tier
                                    {tier}
                                    currency={selectedCurrency}
                                    selected={selected === tier}
                                    term={selectedTerm}
                                    on:changed={(e) => {
                                        const amount = e.detail;
                                        console.log(amount);
                                        selected = tier;
                                        selectedAmount = amount.amount;
                                        selectedTerm = amount.term;
                                    }}
                                />
                            {/if}
                        {/each}
                    </div>

                    <div
                        class="justify-center items-stretch gap-5 flex-col-reverse sm:flex-row flex w-full"
                    >
                        <button
                            class="button !bg-white/10 text-neutral-400 font-normal btn-rounded px-6"
                            on:click={() => closeModal() }
                        >Cancel</button>
                        {#if selectedAmount && selectedCurrency}
                            <button
                                class="button button-primary px-10 text-lg grow"
                                disabled={!selectedAmount}
                                on:click={() => bitcoin = true}
                            >
                                {#if hasTiers}
                                    Go backstage
                                {:else}
                                    Subscribe
                                {/if}
                                for {currencyFormat(selectedCurrency, selectedAmount)}/{termToShort(selectedTerm)}
                            </button>
                        {/if}
                    </div>
                </div>
            {:else}
                <div class="flex flex-col flex-nowrap gap-6 items-center" transition:slide>
                    {#if !userHasWalletConnected}
                        <div class="text-center text-white text-base font-normal leading-normal">
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
                            tier={selected}
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
