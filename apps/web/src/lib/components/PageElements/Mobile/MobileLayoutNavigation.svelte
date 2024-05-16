<script lang="ts">
    import { page } from "$app/stores";
	import { goto } from "$app/navigation";
    import { Icon, Tabbar, TabbarLink, Toolbar } from "konsta/svelte";
	import { Bell, BookmarkSimple, Fire, House, Plus } from "phosphor-svelte";

    const isLabels = true;
    const isIcons = true;
</script>

<Tabbar
    labels={isLabels}
    icons={isIcons}
    class="left-0 bottom-0 fixed"
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
        active={false}
    >
        <svelte:fragment slot="icon">
            <Fire class="w-8 h-8" />
        </svelte:fragment>
        <svelte:fragment slot="label">Discover</svelte:fragment>
    </TabbarLink>
    <TabbarLink
        active={$page.url.pathname.startsWith('/notifications')}
        onClick={() => goto("/notifications")}
    >
        <svelte:fragment slot="icon">
            <Bell class="w-8 h-8" />
        </svelte:fragment>
        <svelte:fragment slot="label">Notifications</svelte:fragment>
    </TabbarLink>
</Tabbar>
