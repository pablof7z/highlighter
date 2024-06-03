<script lang="ts">
	import ModalShell from '$components/ModalShell.svelte';
    import UserProfile from '$components/User/UserProfile.svelte';
    import { userFollows } from '$stores/session';
	import type { NDKIntervalFrequency, NDKSubscriptionTier, NDKUser } from "@nostr-dev-kit/ndk";
    import Tier from "$components/Tier.svelte";
	import type { Readable } from "svelte/motion";
	import { derived } from "svelte/store";
	import { termToShort } from "$utils/term";
	import WalletConnect from '$components/Payment/WalletConnect.svelte';
	import Subscribe from '$components/Payment/Subscribe.svelte';
	import { closeModal } from '$utils/modal';
	import { onMount } from 'svelte';
	import ThankYou from '$components/Payment/ThankYou.svelte';
	import { isNwcAvailable } from '$utils/nwc';
	import { currencyCode, currencyFormat } from '$utils/currency';
	import type { UserProfileType } from '../../app';
	import EmptyTierForm from '$components/EmptyTierForm.svelte';
	import { getUserSubscriptionTiersStore } from '$stores/user-view';
    import createDebug from 'debug';
    import {requestProvider} from 'webln';
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import RadioButton from '$components/Forms/RadioButton.svelte';
	import { createSubscriptionEvent } from '$components/Payment/subscription-event';
	import ManualPayment from '$components/Payment/ManualPayment.svelte';

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

    let manualPayment = false;

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

        if ($tiers.length > 0 && (
            !selected || $tiers.find((tier) => tier.id === selected!.id) === undefined
        ) && selectedCurrency) {
            const tier = $tiers[0];
            const amount = tier.amounts.find((amount) => amount.currency === selectedCurrency);
            if (amount) {
                selected = tier;
                selectedAmount = amount.amount;
                selectedTerm = amount.term;
            }
        }

        return Array.from(currencies);
    });

    async function onPaid() {
        paid = true;
        if ($userFollows.has(user.pubkey)) return;
        $loggedInUser.follow(user);
    }
</script>

<ModalShell color="glassy" class="md:max-w-5xl w-fit">
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div on:click|preventDefault|stopPropagation={() => {}} class="w-full relative transition-all duration-1000">
        <div class="w-full flex justify-center mb-4">
            <UserProfile {user}>
                <AvatarWithName {user} avatarType="square" spacing="gap-4" nameClass="text-white text-xl" />
            </UserProfile>
        </div>

        {#if !paid}
            {#if !bitcoin}
                <div class="flex flex-col flex-nowrap gap-6 items-stretch sm:items-center">
                    {#if $availableCurrencies.length > 1}
                        <div class="flex flex-row gap-2 bg-white/10 rounded-box">
                            {#each $availableCurrencies as currency}
                                <RadioButton
                                    bind:currentValue={selectedCurrency}
                                    value={currency}
                                    label={currencyCode(currency)}
                                    class="w-fit whitespace-nowrap !p-2 !px-4"
                                    skipCheck={true}
                                >
                                    {currencyCode(currency)}
                                </RadioButton>
                            {/each}
                        </div>
                    {/if}

                    <div class="
                        flex flex-col md:flex-row gap-4 items-start overflow-y-auto max-sm:max-h-[50vh]
                        sm:max-w-[60vw] sm:overflow-x-auto overscroll-contain max-sm:snap-y sm:snap-x
                        snap-mandatory pb-8
                    ">
                        {#if $tiers.length === 0}
                            <EmptyTierForm
                                bind:selectedAmount
                                bind:currency={selectedCurrency}
                                {userProfile}
                                term={selectedTerm}
                            />
                        {/if}
                        {#each $tiers as tier (tier.id)}
                            {#if tier.amounts.some(amount => amount.currency === selectedCurrency)}
                                <Tier
                                    {tier}
                                    currency={selectedCurrency}
                                    selected={selected?.id === tier?.id}
                                    term={selectedTerm}
                                    on:changed={(e) => {
                                        const amount = e.detail;
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
                                class="button"
                                disabled={!selectedAmount}
                                on:click={() => bitcoin = true}
                            >
                                {#if hasTiers}
                                    Subscribe
                                {:else}
                                    Support
                                {/if}
                                for {currencyFormat(selectedCurrency, selectedAmount)}/{termToShort(selectedTerm)}
                            </button>
                        {/if}
                    </div>
                </div>
            {:else if manualPayment && selectedAmount && selectedCurrency}
                {#await createSubscriptionEvent(
                    $ndk, selectedAmount.toString(), selectedCurrency, selectedTerm, user, selected
                ) then subscribeEvent}
                    <ManualPayment
                        event={subscribeEvent}
                        recipient={user}
                        on:paid={onPaid}
                    />

                    <div class="flex flex-row items-center justify-between mt-6">
                        <button on:click={() => manualPayment = false}>
                            Back
                        </button>

                        <button on:click={closeModal}>
                            Cancel
                        </button>
                    </div>
                {/await}
            {:else}
                <div class="flex flex-col flex-nowrap gap-6 items-center">
                    {#if !userHasWalletConnected}
                        <h1 class="text-2xl text-center text-white font-semibold leading-normal">
                            Connect your wallet
                        </h1>

                        <WalletConnect
                            bind:mode={nwcMode}
                            bind:nwcUrl
                            on:connected={onWalletConnected}
                            pubkey={user.pubkey}
                            term={selectedTerm}
                            amount={selectedAmount}
                            currency={selectedCurrency}
                            tier={selected}
                        />

                        <button class="font-normal" on:click={() => { manualPayment = true }}>
                            Or
                            <span class="text-base-100-content">proceed without connecting a wallet</span>
                        </button>
                        
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
