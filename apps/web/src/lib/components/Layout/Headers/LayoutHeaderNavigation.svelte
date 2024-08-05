<script lang="ts">
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { ScrollArea } from "$components/ui/scroll-area";
	import SearchModal from "$modals/SearchModal.svelte";
	import { layout } from "$stores/layout";
	import { openModal } from "$utils/modal";
	import { House, MagnifyingGlass } from "phosphor-svelte";
	import { slide } from "svelte/transition";

    export let scrollDir: 'up' | 'down' | undefined;

    function search() {
        openModal(SearchModal);
    }

	$: options = $layout.navigation ?? [
        { id: 'search', tooltip: "Search", icon: MagnifyingGlass, fn: search },
        { id: 'home', tooltip: "Home", icon: House, href: "/", iconProps: { weight: 'fill' } },
        { name: "Reads", href: "/reads" },
        { name: "Watch", href: "/videos" },
        { name: "Highlights", href: "/highlights" },
        { name: "Communities", href: '/communities' },
        { name: "Posts", href: '/notes' },
        { name: "Wiki", href: '/wiki' },
        { name: "Books", href: '/books' },
    ];
</script>

{#if options && (scrollDir !== 'down' || $layout.forceShowNavigation)}
    <div transition:slide>
        <ScrollArea class="py-1 responsive-padding lg:py-3 lg:px-4 whitespace-nowrap {$$props.class??""}" orientation="horizontal">
            <HorizontalOptionsList
                {options}
                bind:activeOption={$layout.activeOption}
                on:changed={() => {
                    $layout.forceShowNavigation = false;
                }}
            />
        </ScrollArea>
    </div>
{/if}