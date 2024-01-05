<script lang="ts">
	import { Article, Video } from 'phosphor-svelte';

    export let filters: App.FilterType[];

    function handleClick(e: MouseEvent, filter: App.FilterType) {
        if (filters.includes(filter)) {
            filters = ["all"];
        } else if (e.shiftKey) {
            filters.push(filter);
            filters = filters;
        } else {
            filters = [filter];
        }
    }
</script>

<div class="justify-end items-center gap-4 inline-flex flex-none self-end w-fit">
    <div class="text-white text-opacity-60 text-sm font-semibold leading-4">Filter:</div>
    <div class="justify-start items-center gap-1 flex">
        <button
            class:active={filters.includes("article")}
            on:click={(e) => handleClick(e, "article")}
        >
            <Article class="w-5 h-5 relative" />
        </button>
        <button
            on:click={(e) => handleClick(e, "video")}
            class:active={filters.includes("video")}
        >
            <Video class="w-5 h-5 relative" />
        </button>
    </div>
</div>

<style lang="postcss">
    button {
        @apply p-2 rounded-lg justify-start items-center gap-1.5 flex;
    }

    button.active {
        @apply bg-white bg-opacity-10;
    }
</style>