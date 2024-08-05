<script lang="ts">
	import { layout } from "$stores/layout";
	import { NavigationOption } from "../../app";
    import { User, GlobeSimple, UsersThree } from "phosphor-svelte";

    const options: NavigationOption[] = [];
    
    options.push({ name: "You", href: '/bookmarks', icon: User})
    options.push({ name: "Follows", href: '/bookmarks/follows', icon: UsersThree})
    options.push({ name: "Recent", href: '/bookmarks/recent', icon: GlobeSimple})

    $layout.title = "Bookmarks";
    $layout.navigation = options;
</script>

<slot />