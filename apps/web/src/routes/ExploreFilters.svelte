<script lang="ts">
	import FilterButtons from "$components/FilterButtons.svelte";
	import OptionsList from "$components/OptionsList.svelte";
	import { NDKKind, type NDKFilter } from "@nostr-dev-kit/ndk";
    import BookmarkSimple from "phosphor-svelte/lib/BookmarkSimple";
    import Hash from "phosphor-svelte/lib/Hash";
    import Plus from "phosphor-svelte/lib/Plus";

    export let value: string;
    export let typeFilter: App.FilterType[];
    export let filters: NDKFilter[] | undefined = undefined;

    let options = [
        { name: "All" },
        { name: "Art", icon: Hash, filters: [{
            kinds: [NDKKind.Article, NDKKind.HorizontalVideo],
            "#t": [ "photography", "art", "artstr"],
            limit: 100,
        }] },
        { name: "Literature", icon: Hash, filters: [{
            kinds: [NDKKind.Article],
            "#t": [ "literature", "book", "bookstr", "books"],
            limit: 100,
        }] },
        { name: "Freedom", icon: Hash, filters: [{
            kinds: [NDKKind.Article, NDKKind.HorizontalVideo],
            "#t": [ "bitcoin", "nostr", "education", "freedom", "politics" ],
            limit: 100,
        }] },
        // { name: "Hot", tooltip: "Coming Soon", icon: Fire },
        // { name: "Controversial", tooltip: "Coming Soon", icon: CircleHalfTilt },
        { name: "Curated", icon: BookmarkSimple },
        // { name: "Backstage", icon: Shapes },
        { name: "", value: 'add', icon: Plus, class: "!bg-zinc-800 !text-white" },
    ]

    function changed(e: CustomEvent) {
        const selectedOption = e.detail;

        debugger;

        value = selectedOption.value;
        filters = selectedOption.filters;
    }
</script>

<div class="w-full justify-between flex flex-nowrap py-2
    items-start sm:items-center overflow-x-auto
    max-sm:flex-col
">
    <div class="justify-start gap-6 flex whitespace-nowrap flex-shrink flex-grow
        max-sm:max-w-[calc(100vw-25px)] overflow-x-auto
        max-sm:border-t border-white/20 py-2
        max-sm:w-full
    ">

        <OptionsList {options} bind:value on:changed={changed} />
    </div>
    <div class="
    flex justify-end
    overflow-clip
    flex-shrink
        bg-base-100 max-sm:py-2
        max-sm:border-y border-white/20 py-2
        max-sm:w-full
    ">
        <FilterButtons bind:filters={typeFilter} />
    </div>
</div>

<style lang="postcss">
    .darken-x {
        @apply !rounded-none;
        @apply relative;
    }

    .darken-x::after {
        @apply absolute top-0 right-0 w-1/6 h-full bg-gradient-to-l from-base-100 to-transparent pointer-events-none;
        content: "";
    }
</style>