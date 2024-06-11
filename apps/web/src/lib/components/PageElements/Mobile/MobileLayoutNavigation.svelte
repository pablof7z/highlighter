<script lang="ts">
    import { page } from "$app/stores";
	import { goto } from "$app/navigation";
    import { Icon, Tabbar, TabbarLink, Toolbar } from "konsta/svelte";
	import { Bell, BookmarkSimple, Fire, House, Plus } from "phosphor-svelte";
	import { showNotificationOption } from "$stores/notifications";
	import { pageHeader } from "$stores/layout";

    const isLabels = true;
    const isIcons = true;

</script>

{#if $pageHeader?.footer}
    <div class="left-0 bottom-0 fixed transition-all duration-300 z-50 w-full hairline-t">
        <svelte:component this={$pageHeader.footer.component} {...$pageHeader.footer.props} />
    </div>
{:else}
    <Tabbar
        labels={isLabels}
        icons={isIcons}
        class="left-0 bottom-0 fixed mobile-navbar transition-all duration-300"
    >
        <TabbarLink
            active={$page.url.pathname.startsWith('/home')}
            onClick={() => goto("/home")}
        >
            <svelte:fragment slot="icon">
                <House class="w-8 h-8" />
            </svelte:fragment>
            <svelte:fragment slot="label">Home</svelte:fragment>
        </TabbarLink>
        <TabbarLink
            active={$page.url.pathname.startsWith('/bookmarks')}
            onClick={() => goto("/bookmarks")}
        >
            <svelte:fragment slot="icon">
                <BookmarkSimple class="w-8 h-8" />
            </svelte:fragment>
            <svelte:fragment slot="label">Bookmarks</svelte:fragment>
        </TabbarLink>
        <TabbarLink
            active={$page.url.pathname.startsWith('/discover')}
            onClick={() => goto("/discover")}
        >
            <svelte:fragment slot="icon">
                <Fire class="w-8 h-8" />
            </svelte:fragment>
            <svelte:fragment slot="label">Discover</svelte:fragment>
        </TabbarLink>
        {#if $showNotificationOption}
            <TabbarLink
                active={$page.url.pathname.startsWith('/notifications')}
                onClick={() => goto("/notifications")}
            >
                <svelte:fragment slot="icon">
                    <Bell class="w-8 h-8" />
                </svelte:fragment>
                <svelte:fragment slot="label">Notifications</svelte:fragment>
            </TabbarLink>
        {/if}
    </Tabbar>
{/if}

<style lang="postcss">
    :global(body.scrolldown .mobile-navbar) {
        opacity: 0.40 !important;
    }
</style>