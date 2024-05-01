<script lang="ts">
	import User from "$components/PageSidebar/OnboardingCheckingIcons/User.svelte";
	import { GlobeSimple, UsersThree } from "phosphor-svelte";
	import BookmarkFeed from "./BookmarkFeed.svelte";
	import { pageMainContentMaxWidth, pageNavigationOptions } from "$stores/layout";
	import { NavigationOption } from "../../../app";
	import { page } from "$app/stores";

    let value: string;
    
    $: value = $page.params.mode ?? "You";

    $pageMainContentMaxWidth = "max-w-3xl";

    const options: NavigationOption[] = [];
    
    options.push({ name: "You", href: '/bookmarks', icon: User})
    options.push({ name: "Follows", href: '/bookmarks/follows', icon: UsersThree})
    options.push({ name: "Recent", href: '/bookmarks/recent', icon: GlobeSimple})

    $pageNavigationOptions = options;
</script>

{#key value}
    <BookmarkFeed type={value} />
{/key}