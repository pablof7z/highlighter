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

<div class="justify-end items-center gap-4 inline-flex flex-none self-end w-full sm:w-fit">
    <div class="justify-between sm:justify-start items-center gap-1 flex w-full">
        <div class="tooltip tooltip-bottom" data-tip="Curations">
            <button
                class:active={filters.includes("curation")}
                on:click={(e) => handleClick(e, "curation")}
            >
                <UserList class="w-8 h-8 sm:w-full sm:h-full relative" />
                <span class="sm:hidden">Curations</span>
            </button>
        </div>
        <div class="tooltip tooltip-bottom" data-tip="Articles">
            <button
                class:active={filters.includes("article")}
                on:click={(e) => handleClick(e, "article")}
            >
                <TextAlignLeft class="w-8 h-8 sm:w-full sm:h-full relative" />
                <span class="sm:hidden">Articles</span>
            </button>
        </div>
        <div class="tooltip tooltip-bottom" data-tip="Videos">
            <button
                on:click={(e) => handleClick(e, "video")}
                class:active={filters.includes("video")}
            >
                <Play class="w-8 h-8 sm:w-full sm:h-full relative" weight="fill" />
                <span class="sm:hidden">Videos</span>
            </button>
        </div>
    </div>
</div>

<style lang="postcss">
    button {
        @apply sm:!p-3 !rounded-2xl justify-start items-center gap-1.5 flex;
        @apply btn bg-base-300 sm:w-12 font-normal;
    }

    button.active {
        @apply bg-white bg-opacity-20;
    }
</style>