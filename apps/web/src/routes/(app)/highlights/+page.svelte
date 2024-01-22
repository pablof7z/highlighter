<script lang="ts">
	import { page } from "$app/stores";
	import ClipItem from "$components/Clips/ClipItem.svelte";
    import FilterButtons from "$components/FilterButtons.svelte";
	import PageSidebar from "$components/PageSidebar.svelte";
	import { userFollows } from "$stores/session";
    import { categories } from '$utils/categories';
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { User } from "phosphor-svelte";
	import { onDestroy } from "svelte";
	import { writable } from "svelte/store";
    import { pageHeader, pageSidebar } from "$stores/layout";
    import HighlightsSidebar from "$components/PageSidebar/Highlights.svelte";
	import PageTitleWithSearch from "$components/Page/PageTitleWithSearch.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import SearchBar from "$components/Page/SearchBar.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";

    const debug = createDebug("highlighter:highlights");

    const typeFilter = writable<App.FilterType[]>(["all"]);
    let selectedCategory: string;
    let open = false;

    $: selectedCategory = $page.params.category || "All";

    const authors = Array.from($userFollows);

    const filters: NDKFilter[] = [ { kinds: [NDKKind.Highlight], limit: 100 } ];

    // If we have authors to filter by, add them to the filter
    if (authors.length > 0) { filters[0].authors = authors; }

    const events = $ndk.storeSubscribe(filters, {
        groupable: false,
        subId: "highlights",
        autoStart: true,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    });

    onDestroy(() => {
        events?.unsubscribe();
        $pageSidebar = null;
    });

    $pageSidebar = {
        component: HighlightsSidebar,
        props: {}
    }

    $pageHeader = {
        title: "Highlights",
    }
</script>

<MainWrapper
    marginClass="max-w-3xl"
    class="gap-8"
>
    {#each $events as event}
        <ClipItem {event} />
    {/each}
</MainWrapper>