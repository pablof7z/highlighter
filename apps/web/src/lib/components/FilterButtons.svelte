<script lang="ts">
	import { Article, Play, TextAlignLeft, UserList, Video } from 'phosphor-svelte';

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
    <div class="justify-start items-center gap-1 flex">
        <div class="tooltip tooltip-bottom" data-tip="Curations">
            <button
                class:active={filters.includes("curation")}
                on:click={(e) => handleClick(e, "curation")}
            >
                <UserList class="w-full h-full relative" />
            </button>
        </div>
        <div class="tooltip tooltip-bottom" data-tip="Articles">
            <button
                class:active={filters.includes("article")}
                on:click={(e) => handleClick(e, "article")}
            >
                <TextAlignLeft class="w-full h-full relative" />
            </button>
        </div>
        <div class="tooltip tooltip-bottom" data-tip="Videos">
            <button
                on:click={(e) => handleClick(e, "video")}
                class:active={filters.includes("video")}
            >
                <Play class="w-full h-full relative" weight="fill" />
            </button>
        </div>
    </div>
</div>

<style lang="postcss">
    button {
        @apply !p-3 !rounded-2xl justify-start items-center gap-1.5 flex;
        @apply btn bg-base-300 w-12;
    }

    button.active {
        @apply bg-white bg-opacity-20;
    }
</style>