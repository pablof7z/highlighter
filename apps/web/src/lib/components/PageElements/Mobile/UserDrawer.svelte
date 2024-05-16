<script lang="ts">
	import { MenuList, MenuListItem, Panel } from "konsta/svelte";
    import { page } from "$app/stores";
    import currentUser, { isGuest } from "$stores/currentUser";
	import { ChalkboardSimple, Gear, House, Timer } from "phosphor-svelte";
	import { goto } from "$app/navigation";

    export let opened = false;


    function go(path: string) {
        goto(path);
        opened = false;
    }
</script>

<Panel
    side="left"
    {opened}
    onBackdropClick={() => opened = false}
>
    <MenuList>
        <MenuListItem
            title="Home"
            active={$page.url.pathname.startsWith('/home')}
            onClick={() => go("/home")}
        >
            <House size={24} slot="media" />
        </MenuListItem>

        <MenuListItem
            title="Schedule"
            active={$page.url.pathname.startsWith('/schedule')}
            onClick={() => go("/schedule")}
        >
            <Timer size={24} slot="media" />
        </MenuListItem>

        <MenuListItem
            title="Drafts"
            active={$page.url.pathname.startsWith('/drafts')}
            onClick={() => go("/drafts")}
        >
            <ChalkboardSimple size={24} slot="media" />
        </MenuListItem>

        <MenuListItem
            title="Settings"
            active={$page.url.pathname.startsWith('/settings')}
            onClick={() => go("/settings")}
        >
            <Gear size={24} slot="media" />
        </MenuListItem>
    </MenuList>
</Panel>