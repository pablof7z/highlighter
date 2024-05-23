<script lang="ts">
	import { onDestroy } from "svelte";
	import { Article, Lightning, Note, Notepad } from "phosphor-svelte";
	import { pageHeader, pageNavigationOptions, resetLayout } from "$stores/layout";
	import HighlightIcon from "$icons/HighlightIcon.svelte";

    onDestroy(() => {
        resetLayout();
    });

    $pageHeader ??= {
        searchBar: true,
        subNavbarOptions: [
            { name: "Home",  href: "/home", icon: Notepad },
            { name: "Notes",  href: "/home/notes", icon: Note },
            { name: "Articles",  href: "/home/articles", icon: Article },
            { name: "Highlights",  href: "/home/highlights", icon: HighlightIcon },
            { name: "Zapped",  href: "/home/zapped", icon: Lightning },
        ],
        subNavbarValue: "Home",
    };
</script>

<slot />