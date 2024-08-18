<script lang="ts">
	import { tierAmountToString } from '$lib/events/tiers';
	import TierAmountLine from "$components/Creator/TierAmountLine.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKSubscriptionAmount, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { slide } from "svelte/transition";
	import { NavigationOption } from "../../../app";
	import { Plus } from "phosphor-svelte";
	import RadioButton from "$components/Forms/RadioButton.svelte";
    import { Writable } from "svelte/store";
	import { CreateState } from ".";

    export let state: Writable<CreateState>;

    export let nextStep;
    export let extraButtons: NavigationOption[];
    nextStep = "create";
    // extraButtons = [ { id: "Pricing Option", icon: Plus, fn: add } ];

    function add() {
        amounts.push({ amount: 0, currency: "USD", term: "monthly" });
        amounts = amounts;
    }
    
    export let title: string;
    title = "Pricing";

    export let buttonLabel: string;
    buttonLabel = "Next: Community details";

    export let tier: NDKSubscriptionTier;
    tier = new NDKSubscriptionTier($ndk);

    tier.title = "Subscribers";
    tier.addAmount(500, "USD", "monthly");

    let amounts: NDKSubscriptionAmount[] = [
        { amount: 5, currency: "USD", term: "monthly" },
    ];

    const presets: NDKSubscriptionAmount[][] = [
        [
            { amount: 200, currency: "USD", term: "monthly" },
            { amount: 2000, currency: "USD", term: "yearly" },
            { amount: 4000, currency: "sats", term: "monthly" }
        ], [
            { amount: 500, currency: "USD", term: "monthly" },
            { amount: 3000, currency: "USD", term: "yearly" },
            { amount: 5000, currency: "sats", term: "monthly" }
        ], [
            { amount: 1000, currency: "USD", term: "monthly" },
            { amount: 8000, currency: "USD", term: "yearly" },
            { amount: 10000, currency: "sats", term: "monthly" }
        ]
    ];

    let selection: string;

    if ($state.amounts && Array.isArray($state.amounts)) {
        const payload = JSON.stringify($state.amounts);
        // go through each preset and see if it matches the payload
        // if it does, set the selection to that preset
        let selected = false;
        for (let i = 0; i < presets.length; i++) {
            if (JSON.stringify(presets[i]) === payload) {
                selected = true
                selection = i.toString();
                break;
            }
        }

        // if no preset matches, set the selection to custom
        if (!selected) {
            selection = "custom";
            amounts = $state.amounts;
        }
    }

    selection ??= "2";

    $: {
        if (selection === "custom") {
            $state.amounts = amounts;
        } else {
            $state.amounts = presets[parseInt(selection)];
        }
    }
</script>

<div class="flex flex-col gap-4 w-full grow">
    <p>
        Choose a price for your subscription tier.
    </p>

    <p class="text-muted-foreground">
        You can add different currency and terms to offer different options.
    </p>

    <div class="grid grid-cols-3 gap-2">
        {#each presets as preset, i}
            <RadioButton color="gold" skipCheck bind:currentValue={selection} value={i.toString()}>
                {#each preset as amount, j}
                    {#if j === 0}
                        <b>
                            {tierAmountToString(amount)}
                        </b>
                    {:else}
                        <div class="text-muted-foreground text-xs whitespace-nowrap">
                            {tierAmountToString(amount)}
                        </div>
                    {/if}
                {/each}
            </RadioButton>
        {/each}
        <RadioButton color="gold" skipCheck bind:currentValue={selection} value="custom" class="col-span-3">
            Custom

            {#if selection === "custom"}
                {#each amounts as amount, i}
                    <div class="w-full" in:slide>
                        <TierAmountLine
                            bind:amount={amount}
                            forceOpen={i === amounts.length - 1}
                            on:delete={() => {
                                amounts = amounts.filter((_, index) => index !== i);
                            }}
                        />
                    </div>
                {/each}
            {/if}
        </RadioButton>
    </div>
</div>