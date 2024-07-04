<script lang="ts">
    import { page } from "$app/stores";
	import { goto } from "$app/navigation";
    import { Icon, Tabbar, TabbarLink, Toolbar } from "konsta/svelte";
	import { Bell, BookmarkSimple, CirclesThree, Fire, House, Plus, TextAlignLeft, YoutubeLogo } from "phosphor-svelte";
	import { hasUnreadNotifications, showNotificationOption, unreadNotifications } from "$stores/notifications";
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
            active={$page.url.pathname === "/"}
            onClick={() => goto("/")}
        >
            <svelte:fragment slot="icon">
                <House class="w-8 h-8" />
            </svelte:fragment>
            <!-- <svelte:fragment slot="label">Home</svelte:fragment> -->
        </TabbarLink>
        <TabbarLink
            active={$page.url.pathname.startsWith('/reads')}
            onClick={() => goto("/reads")}
        >
            <svelte:fragment slot="icon">
                <TextAlignLeft class="w-8 h-8" />
            </svelte:fragment>
            <!-- <svelte:fragment slot="label">Bookmarks</svelte:fragment> -->
        </TabbarLink>

        <TabbarLink
            active={$page.url.pathname.startsWith('/chat')}
            onClick={() => goto("/chat")}
        >
            <svelte:fragment slot="icon">
                <CirclesThree class="w-8 h-8" />
            </svelte:fragment>
            <!-- <svelte:fragment slot="label">Bookmarks</svelte:fragment> -->
        </TabbarLink>
        
        <TabbarLink
            active={$page.url.pathname.startsWith('/videos')}
            onClick={() => goto("/videos")}
        >
            <svelte:fragment slot="icon">
                <YoutubeLogo class="w-8 h-8" />
            </svelte:fragment>
            <!-- <svelte:fragment slot="label">Bookmarks</svelte:fragment> -->
        </TabbarLink>
        {#if $showNotificationOption}
            <TabbarLink
                active={$page.url.pathname.startsWith('/notifications')}
                onClick={() => goto("/notifications")}
            >
                <div slot="icon" class="relative">
                    <Bell class="w-8 h-8" />
                    {#if $hasUnreadNotifications}
                        <div class="absolute -top-1 -right-1 w-4 h-4 bg-accent rounded-full text-xs flex items-center justify-center">
                            {$unreadNotifications}
                        </div>
                    {/if}
                </div>
                <!-- <svelte:fragment slot="label">Notifications</svelte:fragment> -->
            </TabbarLink>
        {/if}
    </Tabbar>
{/if}

<style lang="postcss">
    :global(body.scrolldown .mobile-navbar) {
        opacity: 0.40 !important;
    }
</style>