<script lang="ts">
	import { onDestroy } from "svelte";
	import { Article, House, Note, Notepad } from "phosphor-svelte";
	import { layoutMode, pageHeader, resetLayout } from "$stores/layout";
	import PageHeader from "$views/HomeLayout/PageHeader.svelte";
	import { appMobileView } from "$stores/app";

    $layoutMode = "full-width";
    
    onDestroy(() => {
        resetLayout();
    });

    $: if ($appMobileView) {
        $pageHeader = {
            subNavbarOptions: [
                { value: "Home",  href: "/home", icon: House },
                { name: "Notes",  href: "/home/notes", icon: Note },
                { name: "Reads",  href: "/home/reads", icon: Article },
                { name: "Highlights",  href: "/home/highlights", icon: Notepad },
            ],
            searchBar: true,
            title: "Home",
        }
    } else {
        $pageHeader = {
            component: PageHeader,
        };
    }
</script>

<slot />