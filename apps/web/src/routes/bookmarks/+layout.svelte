<script lang="ts">
	import { pageHeader, resetLayout } from "$stores/layout";
    import { onDestroy } from "svelte";
	import { NavigationOption } from "../../app";
    import { User, GlobeSimple, UsersThree } from "phosphor-svelte";
	import PageTitle from "$components/PageElements/PageTitle.svelte";

    const options: NavigationOption[] = [];
    
    options.push({ name: "You", href: '/bookmarks', icon: User})
    options.push({ name: "Follows", href: '/bookmarks/follows', icon: UsersThree})
    options.push({ name: "Recent", href: '/bookmarks/recent', icon: GlobeSimple})

    let defaultTitle = "Bookmarks";

    $pageHeader = {
        title: defaultTitle,
        subNavbarOptions: options,
        subNavbarValue: "You"
    }

    onDestroy(resetLayout);
</script>

<PageTitle title="Bookmarks" />

<slot />