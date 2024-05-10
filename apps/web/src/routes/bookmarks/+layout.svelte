<script lang="ts">
	import { pageHeader, pageNavigationOptions, resetLayout } from "$stores/layout";
    import { onDestroy } from "svelte";
	import { NavigationOption } from "../../app";
    import { User, GlobeSimple, UsersThree } from "phosphor-svelte";

    const options: NavigationOption[] = [];
    
    options.push({ name: "You", href: '/bookmarks', icon: User})
    options.push({ name: "Follows", href: '/bookmarks/follows', icon: UsersThree})
    options.push({ name: "Recent", href: '/bookmarks/recent', icon: GlobeSimple})

    $pageHeader = {
        title: "Bookmarks",
        searchBar: true
    }

    $pageNavigationOptions = options;

    onDestroy(resetLayout);
</script>

<slot />