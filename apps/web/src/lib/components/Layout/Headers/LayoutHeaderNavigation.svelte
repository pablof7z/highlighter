<script lang="ts">
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { ScrollArea } from "$components/ui/scroll-area";
	import { layout } from "$stores/layout";

	$: options = $layout.navigation ?? [
        { name: "Home", href: "/" },
        { name: "Reads", href: "/reads" },
        { name: "Watch", href: "/videos" },
        { name: "Communities", href: '/communities' },
        { name: "Posts", href: '/notes' },
        { name: "Wiki", href: '/wiki' },
    ];
</script>

{#if options}
    <ScrollArea class="whitespace-nowrap" orientation="horizontal">
        <HorizontalOptionsList {options} class="px-4" />
    </ScrollArea>
{/if}