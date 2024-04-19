<script lang="ts">
	import OptionsList from "$components/OptionsList.svelte";
	import { Option } from "$components/option";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { Bookmark, Lightning, NewspaperClipping, Notepad, User } from "phosphor-svelte";

    const options: Option[] = [];

    options.push({ name: "Feed", href: "/home/notes", icon: Notepad})
    options.push({ name: "Articles", href: "/home/articles", icon: NewspaperClipping})
    options.push({ name: "Highlights", href: "/home", icon: HighlightIcon})
    options.push({ name: "For You", href: "/home/for-you", icon: User})
    options.push({ name: "Bookmarks", href: "/home/bookmarks", icon: Bookmark})
    options.push({ name: "ZAPPED", href: "/home/zapped", icon: Lightning})
</script>

<OptionsList {options} class="md:flex-col w-full max-sm:gap-0 gap-2" />