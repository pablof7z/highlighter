<script lang="ts">
	import TierAmountLine from './TierAmountLine.svelte';
    import type { NDKArticle, NDKTag } from "@nostr-dev-kit/ndk";
	import Input from "$components/Forms/Input.svelte";
	import { possibleTerms, type Term } from "$utils/term";
	import { Textarea } from "@kind0/ui-common";
    import { createEventDispatcher } from "svelte";
	import Tier from '$components/Tier.svelte';
	import { debugMode } from '$stores/session';
	import { Check, Trash, Plus } from 'phosphor-svelte';

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
</script>

<div class="w-full p-6 bg-base-200 rounded-xl flex-col">
    <div class="self-stretch flex-col justify-start items-start gap-6 flex">
        <div class="flex flex-col w-full gap-2">
            <Input
                color="black"
                label="Tier Name"
                placeholder="Tier Name"
                class="w-full"
                bind:value={name}
                {autofocus}
            />
            <Textarea
                color="black"
                label="Description"
                placeholder="Description"
                class="w-full !bg-transparent"
                bind:value={description}
            />
            <div class="text-xs opacity-60">
                What will your fans get by subscribing?
            </div>

            <div class="text-white font-semibold leading-snug mt-2">Perks</div>
            {#each perks as perk, i}
                <div class="flex flex-row gap-2 w-full items-center">
                    <div class="relative w-full flex-grow flex flex-row items-center">
                        <Input
                            color="black"
                            bind:value={perk}
                            class="w-full pl-12 text-sm"
                        />
                        <Check
                            class="w-8 absolute left-2 text-success"
                        />
                    </div>
                    <button class="text-white font-semibold text-sm flex flex-row gap-2 px-2"
                        on:click={() => deletePerk(i)}
                    >
                        <Trash />
                    </button>

                </div>
            {/each}

            <button class="button self-start font-semibold text-sm flex flex-row gap-2 px-2"
                on:click={addPerk}
            >
                <Plus />
                Add Perk
            </button>
        </div>


        <div class="w-full flex flex-col gap-4">
            <div class="w-full flex flex-col lg:flex-row items-end gap-2">
                <div class="text-white font-semibold leading-snug">
                    Pricing Options
                </div>
                <div class="text-xs font-light">
                    You can use different currencies and paying intervals
                </div>
            </div>
            <div class="self-stretch flex-col justify-start items-start gap-2 flex">
                {#each amountLines as amount}
                    <TierAmountLine
                        bind:value={amount}
                        on:delete={() => {
                            amountLines = amountLines.filter((a) => a !== amount);
                        }}
                    />
                {/each}
            </div>
            <div class="self-stretch justify-between items-center inline-flex">
                <button class="button" on:click={addAmountLine}>
                    Add another pricing option
                </button>
                <div class="px-3 py-1.5 rounded-lg justify-center items-center gap-2 flex">
                    <button
                        class="text-rose-400 text-[15px] font-normal leading-snug"
                        on:click={deleteTier}
                    >Delete Tier</button>
                </div>
            </div>
        </div>
    </div>
</div>
