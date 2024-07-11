<script lang="ts">
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { ScrollArea } from "$components/ui/scroll-area";
	import SearchModal from "$modals/SearchModal.svelte";
	import { layout } from "$stores/layout";
	import { openModal } from "$utils/modal";
	import { House, MagnifyingGlass } from "phosphor-svelte";

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

{#if options}
    <ScrollArea class="border whitespace-nowrap {$$props.class??""}" orientation="horizontal">
        <HorizontalOptionsList {options} />
    </ScrollArea>
{/if}