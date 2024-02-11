<script lang="ts">
    import { Bell, CaretLeft, List, MagnifyingGlass, X } from "phosphor-svelte";
    import { Avatar, pageDrawerToggle, rightSidebar, user } from "@kind0/ui-common";
	import { pageHeader, sidebarPlacement } from "$stores/layout";
	import LogoSmall from "$icons/LogoSmall.svelte";
	import UserDrawer from "$components/PageSidebar/UserDrawer.svelte";
	import SearchBar from "$components/Page/SearchBar.svelte";
	import HeaderLeftButton from "./HeaderLeftButton.svelte";
	import HeaderRightButton from "./HeaderRightButton.svelte";
	import SectionHeader from "./SectionHeader.svelte";

    function showMenu() {
        $sidebarPlacement = "left";
        $rightSidebar = {
            component: UserDrawer,
            props: {}
        }
    }

    let searchBar = false;

    function toggleSearch() {
        searchBar = !searchBar;
    }

    // function onChange(e:

    // }
</script>

<div class="navbar fixed z-50 mobile-nav px-3 w-full grid grid-cols-5 gap-1 !py-0 mb-0 min-h-0 h-12">
    {#if $pageHeader?.component}
        <SectionHeader />
    {:else if !searchBar}
        <div class="navbar-start">
            {#if $pageHeader?.left}
                <HeaderLeftButton />
            {:else}
                <label for="draw" class="swap" on:click={showMenu}>
                    <input id="draw" type="checkbox" class="hidden" bind:checked={$pageDrawerToggle} />
                    {#if $user}
                        <Avatar user={$user} size="small" type="circle" class="swap-off" />
                    {:else}
                        <List class="swap-off w-8 h-8" />
                    {/if}
                    <X class="swap-on w-8 h-8" />
                </label>
            {/if}
        </div>
        <div class="navbar-center max-w-[60vw] overflow-clip col-span-3 max-sm:flex-col">
            <span class="text-base text-white text-center w-full whitespace-nowrap overflow-clip font-medium">
                {#if $pageHeader?.title}
                    {$pageHeader.title}
                {:else}
                    <LogoSmall class="h-8" />
                {/if}
            </span>
        </div>
        <div class="navbar-end justify-self-end"
            class:overflow-hidden={$pageHeader?.title}
        >
            {#if $pageHeader?.right}
                <HeaderRightButton />
            {:else}
                <button class="" on:click={toggleSearch}>
                    <MagnifyingGlass class="w-6 h-6" />
                </button>
                <!-- <a href="/notifications" class="btn btn-ghost btn-circle">
                    <Bell class="w-5 h-5" />
                </a> -->
            {/if}
        </div>
    {:else}
        <div class="flex flex-row items-center w-full gap-2 col-span-5">
            <button class="flex-none" on:click={toggleSearch}>
                <CaretLeft class="w-5 h-5" />
            </button>

            <SearchBar autofocus={true} on:searched={toggleSearch} on:dismiss={() => searchBar = false} />
        </div>
    {/if}
</div>

<div class="h-12"></div>