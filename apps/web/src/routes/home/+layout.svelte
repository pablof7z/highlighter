<script lang="ts">
	import { onDestroy } from "svelte";
	import { Article, BookmarkSimple, Note, Notepad } from "phosphor-svelte";
	import { detailView, layoutNavState, pageNavigationOptions, resetLayout } from "$stores/layout";
	import HighlightIcon from "$icons/HighlightIcon.svelte";

    $layoutNavState = 'normal';

    onDestroy(() => {
        resetLayout();
        $detailView = null;
    });

    $pageNavigationOptions = [
        { name: "Home",  href: "/home", icon: Notepad },
        { name: "Notes",  href: "/home/notes", icon: Note },
        { name: "Articles",  href: "/home/articles", icon: Article },
        { name: "Highlights",  href: "/home/highlights", icon: HighlightIcon },
        { name: "Bookmarked",  href: "/bookmarks", icon: BookmarkSimple },
    ]
</script>

<slot />