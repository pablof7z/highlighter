<script lang="ts">
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { ScrollArea } from "$components/ui/scroll-area";
	import { layout } from "$stores/layout";
	import { House, MagnifyingGlass } from "phosphor-svelte";

    export let scrollDir: 'up' | 'down' | undefined;

	$: options = $layout.navigation ?? [
        // { id: 'search', href: '/search', tooltip: "Search", icon: MagnifyingGlass, fn: search },
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
    <ScrollArea class="py-1 lg:py-1.5 lg:px-4 whitespace-nowrap {$$props.class??""}" orientation="horizontal">
        <HorizontalOptionsList
            {options}
            bind:activeOption={$layout.activeOption}
            on:changed={() => {
                $layout.forceShowNavigation = false;
            }}
        />
    </ScrollArea>
{/if}