<script lang="ts">
	import { Block, MenuList, MenuListItem, Navbar, Page, Panel, Link } from "konsta/svelte";
    import { page } from "$app/stores";
    import currentUser, { isGuest } from "$stores/currentUser";
	import { ChalkboardSimple, Door, Gear, House, PaperPlaneTilt, CardsThree, Timer, Moon, Sun, TextAlignLeft, YoutubeLogo } from "phosphor-svelte";
	import { goto } from "$app/navigation";
	import { logout } from "$utils/login";
	import Avatar from '$components/User/Avatar.svelte';
	import UserProfile from "$components/User/UserProfile.svelte";
	import { openModal } from "$utils/modal";
	import NewItemModal from "$modals/NewItemModal.svelte";
	import { toggleMode } from "mode-watcher";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import ToggleDark from "$components/buttons/ToggleDark.svelte";

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
                href="/"
                onClick={() => opened = false}
            >
                <House size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Reads"
                href="/reads"
                onClick={() => opened = false}
            >
                <TextAlignLeft size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Watch"
                href="/videos"
                onClick={() => opened = false}
            >
                <YoutubeLogo size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Collections"
                href="/collections"
                onClick={() => opened = false}
            >
                <CardsThree size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Schedule"
                href="/schedule"
                onClick={() => opened = false}
            >
                <Timer size={24} slot="media" />
            </MenuListItem>

            <MenuListItem
                title="Drafts"
                href="/drafts"
                onClick={() => opened = false}
            >
                <ChalkboardSimple size={24} slot="media" />
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

        <MenuList>
            <MenuListItem>
                <HorizontalOptionsList options={[
                    { component: { component: ToggleDark }, id: 'toggle' },
                    { icon: Door, fn: () => { logout(); opened = false; }, id: 'logout' }
                ]} />
            </MenuListItem>
            
            <MenuListItem
                title="Settings"
                href="/settings"
                onClick={() => opened = false}
            >
                <Gear size={24} slot="media" />
            </MenuListItem>
        
            {#if $currentUser}
                <UserProfile user={$currentUser} let:userProfile let:authorUrl>
                    <MenuListItem title={userProfile?.name??""} onClick={() => go(authorUrl)}>
                        <Avatar user={$currentUser} {userProfile} size="tiny" slot="media" />
                    </MenuListItem>
                </UserProfile>
            {/if}
        </MenuList>
    </Block>
    </Page>
</Panel>