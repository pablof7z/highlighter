<script lang="ts">
    import { categories as allCategories } from "$utils/categories";
	import { CaretDown } from "phosphor-svelte";
	import { slide } from "svelte/transition";
    import { createEventDispatcher } from "svelte";
	import { Input } from "$components/ui/input";

    export let categories: string[] = [];
    export let show = true;

    const dispatch = createEventDispatcher();

    let _categories: Record<string, boolean> = {};

    $: {
        for (const category of allCategories) {
            if (_categories[category] === undefined) {
                _categories[category] = categories.includes(category);
            }
        }

        categories = Object.keys(_categories).filter(category => _categories[category]);
    }

    let selectedString = "";

    function updateSelectedString(changingTier?: string) {
        if (categories.length === 0) {
            selectedString = "Select";
            return;
        } else {
            selectedString = categories.join(", ");
        }
        selectedString = categories.join(", ");

        dispatch("change", categories);
    }

    updateSelectedString();

    $: if (categories) {
        updateSelectedString();
    }

    let newOption: string | undefined = undefined;

    function keydown(event: KeyboardEvent) {
        if (event.key === "Enter") {
            if (newOption) {
                _categories[newOption] = true;
                newOption = undefined;
                updateSelectedString();
            }
        }
    }
</script>

<div class="self-stretch rounded-xl border border-neutral-800 items-start inline-flex bg-transparent flex-col justify-start gap-4">
    <button on:click={() => show = !show} class="text-neutral-300 text-base px-4 py-3 font-normal w-full text-left flex flex-row justify-between bg-black !rounded">
        <div class="flex flex-row items-end gap-4">
            {selectedString}
            {#if selectedString === "Free"}
                <div class="font-light text-sm opacity-50">
                    Content will be publicly visible
                </div>
            {/if}
        </div>
        <CaretDown />
    </button>
    {#if show}
        <div class="flex flex-col gap-3 justify-stretch w-full menu flex-nowrap" transition:slide>
            <li>
                <label class="w-full flex flex-row gap-4">
                    <Input
                        bind:value={newOption}
                        class="w-full"
                        color="black"
                        placeholder="Add a new category"
                        on:keydown={keydown}
                    />
                </label>
            </li>
            {#each Object.keys(_categories) as category, i}
                {#if _categories[category]}
                    <li>
                        <label class="w-full flex flex-row gap-4">
                            <input type="checkbox" class="checkbox" bind:checked={_categories[category]} on:change={() => updateSelectedString(category)} />
                            <span class="w-full">{category}</span>
                        </label>
                    </li>
                {/if}
            {/each}
            {#each allCategories as category}
                {#if !_categories[category]}
                    <li>
                        <label class="w-full flex flex-row gap-4">
                            <input type="checkbox" class="checkbox" bind:checked={_categories[category]} on:change={() => updateSelectedString(category)} />
                            <span class="w-full">{category}</span>
                        </label>
                    </li>
                {/if}
            {/each}
        </div>
    {/if}
</div>