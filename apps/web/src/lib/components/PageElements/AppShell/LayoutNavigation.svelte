<script lang="ts">
	import { layoutNavState } from "$stores/layout";
    import OptionsList from "$components/OptionsList.svelte";
	import { Bell, BookmarkSimple, Fire, Gear, House, PaperPlaneTilt, SquaresFour } from "phosphor-svelte";
	import { NavigationOption } from "../../../../app";
	import { openModal } from "svelte-modals";
	import NewItemModal from "$modals/NewItemModal.svelte";
    import currentUser from "$stores/currentUser";
	import CurrentUser from "$components/CurrentUser.svelte";

    function toggle() {
        if ($layoutNavState === "collapsed") {
            $layoutNavState = "normal";
        } else {
            $layoutNavState = "collapsed";
        }
    }

    let layoutNavWidth: string;
    $: layoutNavWidth = $layoutNavState === "collapsed" ? "w-20" : "pl-6";

    const options: NavigationOption[] = [
        { name: "Home", icon: House, href: "/home" },
        { name: "Bookmarks",  href: "/bookmarks", icon: BookmarkSimple },
        { name: "Discover",  href: "/", icon: Fire },
        { name: "Notifications", icon: Bell, href: "/home/for-you"},
        { name: "Publish", icon: PaperPlaneTilt, fn: () => openModal(NewItemModal) },
    ]

    const bottomOptions: NavigationOption[] = [
        { name: "Settings", icon: Gear, href: "/settings" },
    ]
</script>

<div class="
    flex flex-col
    sm:top-[var(--layout-header-height)]
    sm:h-full
    overflow-hidden z-[50000]
    hover:overflow-visible
    flex-none

    max-sm:fixed max-sm:bottom-0 max-sm:left-0 max-sm:right-0
    max-sm:w-full

    {layoutNavWidth}
    {$$props.class??""}
">
    <!-- Mobile view -->
    <div class="btm-nav sm:hidden fixed z-[500] !bg-black">
        <a href="/home">
            <House class="w-8 h-8" />
        </a>
        <a href="/bookmarks">
            <BookmarkSimple class="w-8 h-8" />
        </a>
        <a href="/">
            <Fire class="w-8 h-8" />
        </a>
        {#if $currentUser}
            <a href="/home/for-you">
                <Bell class="w-8 h-8" />
            </a>
        {:else}
            <CurrentUser />
        {/if}
    </div>

    <!-- Normal view -->
    <div class="
        max-sm:hidden flex flex-col h-full justify-between
        sm:pr-6
    ">
        <OptionsList {options} class="flex-col w-full" collapsed={$layoutNavState === 'collapsed'} />
    </div>

    <div class="flex flex-col fixed bottom-0 max-sm:hidden">
        <OptionsList options={bottomOptions} class="flex-col w-full" collapsed={$layoutNavState === 'collapsed'} />
    </div>
</div>