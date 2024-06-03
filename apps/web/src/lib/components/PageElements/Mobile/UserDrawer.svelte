<script lang="ts">
	import { Block, MenuList, MenuListItem, Navbar, Page, Panel, Link } from "konsta/svelte";
    import { page } from "$app/stores";
    import currentUser, { isGuest } from "$stores/currentUser";
	import { ChalkboardSimple, Door, Gear, House, PaperPlaneTilt, CardsThree, Timer } from "phosphor-svelte";
	import { goto } from "$app/navigation";
	import { logout } from "$utils/login";
	import Avatar from '$components/User/Avatar.svelte';
	import UserProfile from "$components/User/UserProfile.svelte";
	import { openModal } from "$utils/modal";
	import NewItemModal from "$modals/NewItemModal.svelte";

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
    <Page class="h-full flex flex-col">
        <Navbar  title="Settings">
            <Link slot="right" onClick={() => (opened = false)}>
                Close
            </Link>
        </Navbar>

        <Block class="space-y-4 !my-0 grow flex flex-col">
        <MenuList class="!my-0">
            <MenuListItem
                title="Home"
                active={$page.url.pathname.startsWith('/home')}
                href="/home"
            >
                <House size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Collections"
                active={$page.url.pathname.startsWith('/collections')}
                href="/collections"
                onClick={() => opened = false}
            >
                <CardsThree size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Schedule"
                active={$page.url.pathname.startsWith('/schedule')}
                href="/schedule"
            >
                <Timer size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Drafts"
                active={$page.url.pathname.startsWith('/drafts')}
                href="/drafts"
            >
                <ChalkboardSimple size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Settings"
                active={$page.url.pathname.startsWith('/settings')}
                href="/settings"
            >
                <Gear size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Publish"
                class="!text-accent"
                onClick={() => {
                    openModal(NewItemModal);
                    opened = false;
                }}
            >
                <PaperPlaneTilt size={24} slot="media" />
            </MenuListItem>
        </MenuList>

    <div class="grow"></div>

        {#if $currentUser}
            <MenuList>
                <UserProfile user={$currentUser} let:userProfile let:authorUrl>
                    <MenuListItem title={userProfile?.name??""} onClick={() => go(authorUrl)}>
                        <Avatar user={$currentUser} {userProfile} size="tiny" slot="media" />
                    </MenuListItem>
                </UserProfile>
                <MenuListItem
                    title="Logout"
                    onClick={() => {
                        logout()
                        opened = false
                    }}
                >
                    <Door size={24} slot="media" />
                </MenuListItem>
            </MenuList>
        {/if}
    </Block>
    </Page>
</Panel>