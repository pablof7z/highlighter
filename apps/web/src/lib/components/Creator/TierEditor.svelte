<script lang="ts">
	import TierAmountLine from './TierAmountLine.svelte';
    import type { NDKSubscriptionAmount, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
	import Input from "$components/Forms/Input.svelte";
	import { Textarea } from "@kind0/ui-common";
    import { createEventDispatcher } from "svelte";
	import { Check, Trash, Plus } from 'phosphor-svelte';
	import { slide } from 'svelte/transition';
	import GlassyInput from '$components/Forms/GlassyInput.svelte';

    export let tier: NDKSubscriptionTier;
    export let autofocus = false;

    const dispatch = createEventDispatcher();

    let name: string;
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
            switch (amount.currency) {
                case 'msat': value *= 1000; break;
                case 'usd', 'eur', 'USD', 'EUR': value *= 100; break;
            }
            tier.addAmount(value, amount.currency, amount.term);
        }

        tier = tier;
    }

    function addAmountLine() {
        let currency = "";
        let amount = 5;

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

<section class="settings">
<div class="w-full sm:p-6 rounded-xl flex-col border border-base-200">
    <div class="self-stretch flex-col justify-start items-start gap-6 flex">
        <section class="settings">
            <h1 class="title">Basic details</h1>
            <div class="description">
                Your potential subscribers will see this before deciding to support your work.
            </div>

            <div class="field">
                <div class="title">
                    Name & Description
                </div>
                <GlassyInput
                    label="Tier Name"
                    placeholder="Tier Name"
                    class="w-full !bg-white/10 !rounded-2xl placeholder:!text-neutral-500 !text-base font-normal border-none"
                    bind:value={name}
                    {autofocus}
                />
                <Textarea
                    color="black"
                    class="w-full !rounded-2xl !bg-white/10 placeholder:!text-neutral-500 border-none"
                    bind:value={description}
                />
            </div>
            <div class="field">
                <div class="title">Perks</div>
                <div class="description">
                    Want to show an itemized list of perks subscribers of this tier get?
                </div>

                <div class="
                    flex flex-col gap-2 rounded-box p-2
                    {perks.length > 0 ? "bg-white/10" : ""}
                ">
                    {#each perks as perk, i}
                        <div class="flex flex-row gap-2 w-full items-center group perk-item" transition:slide>
                            <div class="relative w-full flex-grow flex flex-row items-center">
                                <GlassyInput
                                    tabindex={i+1}
                                    autofocus={i === perks.length - 1}
                                    bind:value={perk}
                                    on:focus={() => perkWithFocus = i}
                                    on:blur={() => perkWithFocus = undefined}
                                    on:keydown={perkKeyDown}
                                    class="w-full pl-12 text-sm !rounded-2xl !bg-transparent border-none font-normal !py-1"
                                />
                                <Check
                                    class="w-8 absolute left-2 text-success"
                                />
                            </div>
                            <button class="
                                text-white font-semibold text-sm flex flex-row gap-2 px-2 transition-all duration-300
                                {perkWithFocus === i ? "sm" : "sm:opacity-0 group-hover:sm:opacity-100" }
                            "
                                on:click={() => deletePerk(i)}
                            >
                                <Trash />
                            </button>
                        </div>
                    {/each}
                </div>
            </div>

            <button class="button font-semibold text-sm flex flex-row gap-2 px-6 self-start"
                    on:click={addPerk}
                    transition:slide
                >
                    <Plus />
                    Add Perk
                </button>
        </section>

        <section class="settings w-full">
            <div class="title">Pricing Options</div>
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
                    <div class="w-full" transition:slide>
                        <TierAmountLine
                            bind:value={amount}
                            on:delete={() => {
                                amounts = amounts.filter((a) => a !== amount);
                            }}
                        />
                    </div>
                {/each}
            </div>

            <button class="button font-semibold text-sm flex flex-row gap-2 px-6 self-start"
                    transition:slide
                    on:click={addAmountLine}
                >
                    <Plus class="w-5 h-5 ml-2" />
                    Add pricing option
                </button>
        </section>

        <div class="px-3 py-1.5 rounded-lg justify-center items-center gap-2 flex">
            <button
                class="text-rose-400 text-[15px] font-normal leading-snug"
                on:click={deleteTier}
            >Delete Tier</button>
        </div>
    </div>
</div>
</section>

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
        @apply text-white font-medium text-lg whitespace-nowrap;
    }

    section .section-info .description {
        @apply text-white/60 font-light text-sm;
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