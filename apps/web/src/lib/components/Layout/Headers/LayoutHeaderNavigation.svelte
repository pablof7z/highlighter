<script lang="ts">
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { ScrollArea } from "$components/ui/scroll-area";
	import { NavigationOption } from "../../../../app";

    export let options: NavigationOption[] | undefined = undefined;

	options ??= [
        { name: "Home", href: "/" },
        { name: "Reads", href: "/reads" },
        { name: "Communities", href: '/communities' },
        { name: "Posts", href: '/notes' },
        { name: "Wiki", href: '/wiki' },
    ];
</script>

<ScrollArea class="whitespace-nowrap border-y border-border py-4" orientation="horizontal">
    <HorizontalOptionsList {options} class="px-4" />
</ScrollArea>