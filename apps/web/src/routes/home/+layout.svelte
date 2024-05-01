<script lang="ts">
	import { onDestroy } from "svelte";
	import { BookmarkSimple, Note, Notepad } from "phosphor-svelte";
	import { detailView, pageNavigationOptions, resetLayout } from "$stores/layout";

    onDestroy(() => {
        resetLayout();
        $detailView = null;
    });

    $pageNavigationOptions = [
        { name: "Home",  href: "/home", icon: Notepad },
        { name: "Notes",  href: "/home/notes", icon: Note },
        { name: "Bookmarked",  href: "/bookmarks", icon: BookmarkSimple },
    ]
</script>

<slot />