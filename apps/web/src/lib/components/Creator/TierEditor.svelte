<script lang="ts">
	import TierAmountLine from './TierAmountLine.svelte';
    import type { NDKSubscriptionAmount, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher } from "svelte";
	import { Check, Trash, Plus } from 'phosphor-svelte';
	import { slide } from 'svelte/transition';
	import GlassyInput from '$components/Forms/GlassyInput.svelte';
    import { Textarea } from "$lib/components/ui/textarea";
	import Input from '$components/ui/input/input.svelte';
	import { Button } from '$components/ui/button';

    export let tier: NDKSubscriptionTier;
    export let autofocus = false;

    const dispatch = createEventDispatcher();

    let name: string = "";
    let description: string;

    let amounts: NDKSubscriptionAmount[] = [];

    let perks: string[] = [];

    name = tier.title || "";
    description = tier.content || "";
    amounts = tier.amounts;
    perks = tier.getMatchingTags("perk").map((perk) => perk[1]);

    if (!perks.length && !tier.dTag) addPerk();

    function addPerk() {
        perks.push("");
        perks = perks;
    }

    function deletePerk(index: number) {
        perks = perks.filter((_, i) => i !== index);
    }

    function filterOutTags(tags: NDKTag[], tagsToRemove: string[]) {
        return tags.filter((tag) => !tagsToRemove.includes(tag[0]) );
    }

    function cleanOutPerks(perks: string[]) {
        return perks
            .filter((perk) => perk !== "")
            .map((perk) => ["perk", perk]);
    }

    $: {
        tier.title = name;
        tier.content = description;
        tier.tags = [
            ...filterOutTags(tier.tags, [
                "amount",
                "perk"
            ]),
            ...cleanOutPerks(perks),
        ];
        for (const amount of amounts) {
            let value = amount.amount;
            tier.addAmount(value, amount.currency, amount.term);
        }

        tier = tier;
    }

    function addAmountLine() {
        let currency = "";
        let amount = 500;

        if (amounts.length > 0) {
            currency = amounts[amounts.length - 1].currency;
            amount = amounts[amounts.length - 1].amount;
        }

        amounts.push({ amount, currency, term: "monthly" });
        amounts = amounts;
    }

    if (amounts.length === 0) {
        addAmountLine();
    }

    function deleteTier() {
        dispatch("delete");
    }

    function perkKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            addPerk();
        } else if (e.key === "Backspace" && e.target.value === "") {
            e.preventDefault();
            deletePerk(perkWithFocus!);

        }
    }

    let allamountsAreComplete = false;

    $: {
        allamountsAreComplete = true;

        for (const amount of amounts) {
            if (!(amount.amount > 0 && amount.currency && amount.term)) {
                allamountsAreComplete = false;
                break;
            }
        }
    }

    let perkWithFocus: number | undefined;
</script>

<div class="w-full rounded-xl flex-col border border-border text-muted-foreground">
    <div class="self-stretch flex-col justify-start items-start gap-6 flex">
        <section class="settings w-full">
            <h3 class="text-foreground font-semibold uppercase">Basic details</h3>
            <div class="description">
                Your potential subscribers will see this before deciding to support your work.
            </div>

            <div class="field">
                <div class="text-foreground uppercase text-sm my-2">
                    Name & Description
                </div>
                <Input
                    placeholder="Tier Name"
                    bind:value={name}
                    class="text-xl py-4 h-fit font-semibold"
                    {autofocus}
                />
                <Textarea bind:value={description} />
            </div>
            <div class="field">
                <div class="title">Perks</div>
                <div class="description">
                    Want to show an itemized list of perks subscribers of this tier get?
                </div>

                <div class="
                    flex flex-col gap-2 rounded p-2
                ">
                    {#each perks as perk, i}
                        <div class="flex flex-row gap-2 w-full items-center group perk-item">
                            <div class="relative w-full flex-grow flex flex-row items-center">
                                <Input
                                    tabindex={i+1}
                                    autofocus={i === perks.length - 1 && name.length > 0}
                                    bind:value={perk}
                                    on:focus={() => perkWithFocus = i}
                                    on:blur={() => perkWithFocus = undefined}
                                    on:keydown={perkKeyDown}
                                    class="px-12 text-sm"
                                />
                                <Check
                                    class="w-8 absolute left-2 text-green-500"
                                />
                                <button class="
                                    absolute right-2 text-foreground font-semibold text-sm flex flex-row gap-2 px-2 transition-all duration-300
                                    {perkWithFocus === i ? "sm" : "sm:opacity-0 group-hover:sm:opacity-100" }
                                "
                                    on:click={() => deletePerk(i)}
                                >
                                    <Trash />
                                </button>
                            </div>
                        </div>
                    {/each}
                </div>
            </div>

            <Button variant="secondary" class="self-start" on:click={addPerk}
            >
                <Plus class="inline mr-2" /> Add Perk
            </Button>
        </section>

        <section class="settings w-full">
            <h3 class="text-foreground font-semibold uppercase">Pricing Options</h3>
            <div class="description flex flex-col gap-2">
                <p>
                    You can use different currencies and paying intervals.
                </p>
                <p class="max-sm:hidden text-xs">
                    E.g. $5/mo, $50/year or 50k sats/month
                </p>
            </div>

            <div class="field self-stretch flex-col justify-start items-stretch w-full gap-2 flex">
                {#each amounts as amount, i}
                    <div class="w-full" in:slide>
                        <TierAmountLine
                            bind:value={amount}
                            on:delete={() => {
                                amounts = amounts.filter((a) => a !== amount);
                            }}
                        />
                    </div>
                {/each}
            </div>

            <Button variant="secondary" class="self-start" on:click={addAmountLine}>
                <Plus class="w-5 h-5 mr-2" />
                Add pricing option
            </Button>
        </section>
<!-- 
        <div class="px-3 py-1.5 rounded-lg justify-between w-full items-center gap-2 flex">
            <button
                class="text-rose-400 text-[15px] font-normal leading-snug"
                on:click={deleteTier}
            >Delete Tier</button>

            <button class="button" on:click={() => dispatch('close')}>
                Continue
            </button>
        </div> -->
    </div>
</div>

<style lang="postcss">
    section.settings {
        @apply gap-4;
    }

    section > .description {
        @apply text-neutral-500 -mt-4;
    }

    section .field .description {
        @apply text-neutral-500 text-sm;
    }
</style>

<!-- <style lang="postcss">
    section {
        @apply flex flex-col lg:flex-row lg:gap-6 w-full;
    }

    section .section-info {
        @apply lg:w-1/3;
        @apply flex sm:flex-col gap-2 items-start;
    }

    section .main {
        @apply lg:w-2/3 flex flex-col w-full;
    }

    section .section-info .title-and-description {
        @apply flex flex-col;
    }

    section .section-info .title {
        @apply text-foreground font-medium text-lg whitespace-nowrap;
    }

    section .section-info .description {
        @apply text-foreground/60 font-light text-sm;
    }

    section .section-info button {
        @apply mt-2 text-xs whitespace-nowrap;
    }

    .perk-item:not(:last-child) {
        @apply border-b border-white/5;
    }

    button[disabled] {
        @apply !opacity-40;
    }
</style> -->