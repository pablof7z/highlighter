<script lang="ts">
    import { Bell, CaretLeft, CaretRight, List, MagnifyingGlass, PaperPlaneTilt, X } from "phosphor-svelte";
    import { pageDrawerToggle, rightSidebar } from "@kind0/ui-common";
	import { pageHeader, sidebarPlacement } from "$stores/layout";
	import Logo from "$icons/Logo.svelte";
	import LogoSmall from "$icons/LogoSmall.svelte";
	import UserDrawer from "$components/PageSidebar/UserDrawer.svelte";
	import SearchBar from "$components/Page/SearchBar.svelte";

    function showMenu() {
        pageDrawerToggle.set(true);
        $sidebarPlacement = "left";
        $rightSidebar = {
            component: UserDrawer,
            props: {}
        }
    }

    function leftClicked() {
        if ($pageHeader?.leftFn) {
            $pageHeader.leftFn();
        }
    }

    function rightClicked() {
        if ($pageHeader?.rightFn) {
            $pageHeader.rightFn();
        }
    }

    let searchBar = false;

    function toggleSearch() {
        searchBar = !searchBar;
    }
</script>

<div class="navbar fixed z-50 mobile-nav h-16 px-3">
    {#if !searchBar}
        <div class="navbar-start">
            {#if $pageHeader?.leftLabel}
                <a
                    href={$pageHeader?.leftUrl??"#"}
                    on:click={leftClicked}
                    class="text-accent2 whitespace-nowrap"
                >
                    {#if $pageHeader.leftLabel === "Back"}
                        <CaretLeft class="w-5 h-5 inline" />
                    {/if}
                {$pageHeader.leftLabel}
                </a>
            {:else}
                <button on:click={showMenu}>
                    <List class="w-8 h-8" />
                </button>
            {/if}
        </div>
        <div class="navbar-center">
            <span class="btn btn-ghost text-xl text-white">
                {#if $pageHeader?.title}
                    {$pageHeader.title}
                {:else}
                    <LogoSmall class="h-8" />
                {/if}
            </span>
        </div>
        <div class="navbar-end">
            {#if $pageHeader?.rightLabel}
                <a
                    href={$pageHeader?.rightUrl??"#"}
                    on:click={rightClicked}
                    class="text-accent2 whitespace-nowrap"
                >
                    {#if $pageHeader.rightLabel === "loading"}
                        <span class="loading loading-sm" />
                    {:else}
                        {$pageHeader.rightLabel}

                        {#if $pageHeader.rightLabel === "Next"}
                            <CaretRight class="w-5 h-5 inline" />
                        {:else if $pageHeader.rightLabel === "Publish"}
                            <PaperPlaneTilt class="w-5 h-5 inline" />
                        {/if}
                    {/if}
                </a>
            {:else}
                <button class="btn btn-ghost btn-circle" on:click={toggleSearch}>
                    <MagnifyingGlass class="w-5 h-5" />
                </button>
                <a href="/notifications" class="btn btn-ghost btn-circle">
                    <div class="indicator">
                        <Bell class="w-5 h-5" />
                        <span class="badge badge-xs bg-accent2 indicator-item"></span>
                    </div>
                </a>
            {/if}
        </div>
    {:else}
        <div class="flex flex-row items-center w-full gap-2">
            <button class="flex-none" on:click={toggleSearch}>
                <CaretLeft class="w-5 h-5" />
            </button>

            <SearchBar autofocus={true} on:searched={toggleSearch} />
        </div>
    {/if}
</div>

<div class="h-16"></div>