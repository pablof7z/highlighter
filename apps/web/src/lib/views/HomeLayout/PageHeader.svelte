<script lang="ts">
	import { Notepad, Note, Article, Lightning, House, BookOpen, BookOpenText, TextAlignLeft } from "phosphor-svelte";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import SearchBar from "$components/Page/SearchBar.svelte";

    const options: NavigationOption[] = [
        { value: "Home",  href: "/home", icon: House },
        { name: "Notes",  href: "/home/notes", icon: Note },
        { name: "Reads",  href: "/home/reads", icon: TextAlignLeft },
        { name: "Highlights",  href: "/home/highlights", icon: HighlightIcon },
        // { name: "Zapped",  href: "/home/zapped", icon: Lightning },
    ]
</script>

<div class="py-2 mx-auto w-full max-w-4xl {$$props.containerClass??""}">
    <div class="flex flex-col w-full gap-2">
        <SearchBar class="!max-w-4xl" />
        
        <div class="flex flex-row items-center justify-between w-full">
            <HorizontalOptionsList {options} />

            <button class="button">
                New
            </button>
        </div>
    </div>
</div>