<script lang="ts">
	import FilterButtons from "$components/FilterButtons.svelte";
	import OptionsList from "$components/OptionsList.svelte";
	import { NDKKind, type NDKFilter } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, CircleHalfTilt, Fire, Plus, Shapes } from "phosphor-svelte";

    export let value: string;
    export let typeFilter: App.FilterType[];
    export let filters: NDKFilter[] | undefined = undefined;

    let options = [
        { name: "All" },
        { name: "Art", filters: [{
            kinds: [NDKKind.Article, NDKKind.HorizontalVideo],
            "#t": [ "photography", "art", "artstr"],
            limit: 100,
        }] },
        { name: "Literature", filters: [{
            kinds: [NDKKind.Article],
            "#t": [ "literature", "book", "bookstr", "books"],
            limit: 100,
        }] },
        { name: "Freedom", filters: [{
            kinds: [NDKKind.Article, NDKKind.HorizontalVideo],
            "#t": [ "bitcoin", "nostr", "education", "freedom", "politics" ],
            limit: 100,
        }] },
        { name: "Hot", tooltip: "Coming Soon", icon: Fire },
        { name: "Controversial", tooltip: "Coming Soon", icon: CircleHalfTilt },
        { name: "Curated", icon: BookmarkSimple },
        { name: "Backstage", icon: Shapes },
        { name: "", value: 'add', icon: Plus, class: "!bg-zinc-800 !text-white" },
    ]

    function changed(e: CustomEvent) {
        const selectedOption = e.detail;

        debugger;

        value = selectedOption.value;
        filters = selectedOption.filters;
    }
</script>

<div class="w-full justify-between items-center flex max-sm:hidden overflow-x-clip flex-nowrap py-2">
    <div class="justify-start items-stretch gap-6 flex whitespace-nowrap flex-shrink">
        <OptionsList {options} bind:value on:changed={changed} />
    </div>
    <FilterButtons bind:filters={typeFilter} />
</div>