<script lang="ts">
	import TierAmountLine from './TierAmountLine.svelte';
    import type { NDKArticle, NDKTag } from "@nostr-dev-kit/ndk";
	import Input from "$components/Forms/Input.svelte";
	import { Textarea } from "@kind0/ui-common";
    import { createEventDispatcher } from "svelte";
	import { Check, Trash, Plus } from 'phosphor-svelte';
	import { slide } from 'svelte/transition';

    export let tier: NDKArticle;
    export let autofocus = false;

    const dispatch = createEventDispatcher();

    let name: string;
    let description: string;

    let amountLines: NDKTag[] = [];

    let perks: string[] = [];

    name = tier.title || "";
    description = tier.content || "";
    amountLines = tier.getMatchingTags("amount");
    perks = tier.getMatchingTags("perk").map((perk) => perk[1]);


    if (!perks.length && !tier.dTag) addPerk();

    function addPerk () {
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
            ...amountLines];
        tier = tier;
    }

    function addAmountLine() {
        let currency = "";
        let amount = "5";

        if (amountLines.length > 0) {
            currency = amountLines[amountLines.length - 1][2];
            amount = amountLines[amountLines.length - 1][1];
        }

        amountLines.push(["amount", amount, currency, ""]);
        amountLines = amountLines;
    }

    if (amountLines.length === 0) {
        addAmountLine();
    }

    function deleteTier() {
        dispatch("delete");
    }

    let allAmountLinesAreComplete = false;

    $: {
        allAmountLinesAreComplete = true;

        for (const amount of amountLines) {
            if (amount[1] === "" || amount[2] === "" || amount[3] === "") {
                allAmountLinesAreComplete = false;
                break;
            }
        }
    }

    let perkWithFocus: number | undefined;
</script>

<div class="w-full p-6 rounded-xl flex-col border border-base-200">
    <div class="self-stretch flex-col justify-start items-start gap-6 flex">
        <section>
            <div class="section-info">
                <div class="title">
                    Basic Details
                </div>
                <div class="description">
                    Your potential subscribers will see this
                    before deciding to support your work.
                </div>
            </div>
            <div class="main gap-2 flex">
                <Input
                    color="black"
                    label="Tier Name"
                    placeholder="Tier Name"
                    class="w-full !bg-white/10 !rounded-2xl placeholder:!text-neutral-500 text-normal font-medium border-none"
                    bind:value={name}
                    {autofocus}
                />
                <Textarea
                    color="black"
                    label="Description"
                    placeholder="Description"
                    class="w-full !rounded-2xl !bg-white/10 placeholder:!text-neutral-500 text-sm text-white/80 border-none"
                    bind:value={description}
                />
            </div>
        </section>

        <section>
            <div class="section-info">
                <div class="title-and-description">
                    <div class="title">Perks</div>
                    <div class="description">
                        Want to show an itemized list of perks
                        subscribers of this tier get?
                    </div>
                </div>
                <button class="button self-start font-semibold text-sm flex flex-row gap-2 px-2"
                    on:click={addPerk}
                    class:hidden={perks.length === 0}
                >
                    <Plus />
                    Add Perk
                </button>
            </div>
            <div class="main">
                <div class="
                    flex flex-col gap-2 rounded-box p-2
                    {perks.length > 0 ? "bg-white/10" : ""}
                ">
                    {#each perks as perk, i}
                        <div class="flex flex-row gap-2 w-full items-center group perk-item" transition:slide>
                            <div class="relative w-full flex-grow flex flex-row items-center">
                                <Input
                                    color="black"
                                    tabindex={i+1}
                                    bind:value={perk}
                                    on:focus={() => perkWithFocus = i}
                                    on:blur={() => perkWithFocus = undefined}
                                    class="w-full pl-12 text-sm !rounded-2xl !bg-transparent border-none !text-white/80"
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

                    {#if perks.length === 0}
                        <button class="button font-semibold text-sm flex flex-row gap-2 px-2"
                            on:click={addPerk}
                            transition:slide
                        >
                            <Plus />
                            Add Perk
                        </button>
                    {/if}
                </div>
            </div>
        </section>

        <section>
            <div class="section-info">
                <div class="title-and-description">
                    <div class="title">Pricing Options</div>
                    <div class="description flex flex-col gap-2">
                        <p>
                            You can use different currencies and paying intervals.
                        </p>
                        <p class="max-sm:hidden">
                            E.g. $5/mo, $50/year or 50k sats/month
                        </p>
                    </div>
                </div>
                <button
                    class="button text-xs max-sm:!mt-0"
                    disabled={!allAmountLinesAreComplete}
                    class:hidden={amountLines.length === 0}
                    on:click={addAmountLine}
                >
                    <Plus class="w-5 h-5 ml-2" />
                    Add
                </button>
            </div>
            <div class="main">
                <div class="self-stretch flex-col justify-start items-stretch w-full gap-2 flex">
                    {#each amountLines as amount, i}
                        <div class="w-full" transition:slide>
                            <TierAmountLine
                                bind:value={amount}
                                on:delete={() => {
                                    amountLines = amountLines.filter((a) => a !== amount);
                                }}
                            />
                        </div>
                    {/each}
                    <button class="button font-semibold text-sm flex flex-row gap-2 px-2"
                        class:hidden={amountLines.length !== 0}
                        transition:slide
                        on:click={addAmountLine}
                    >
                        <Plus class="w-5 h-5 ml-2" />
                        Add pricing option
                    </button>
                </div>
            </div>
        </section>

        <div class="px-3 py-1.5 rounded-lg justify-center items-center gap-2 flex">
            <button
                class="text-rose-400 text-[15px] font-normal leading-snug"
                on:click={deleteTier}
            >Delete Tier</button>
        </div>
    </div>
</div>

<style lang="postcss">
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
        @apply text-white font-medium text-lg;
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
</style>