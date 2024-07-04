<script lang="ts">
	import { Block, MenuList, Navbar, Page, Panel, Link } from "konsta/svelte";
    import { Button } from "$components/ui/button";
    import currentUser, { isGuest } from "$stores/currentUser";
	import { ChalkboardSimple, Door, Gear, House, PaperPlaneTilt, CardsThree, Timer, Moon, Sun, TextAlignLeft, YoutubeLogo, CirclesFour } from "phosphor-svelte";
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
        <Navbar title="Settings">
            <Link slot="right" onClick={() => (opened = false)}>
                Close
            </Link>
        </Navbar>

        <Block class="space-y-4 grow flex flex-col">
            <div class="!my-0 flex flex-col gap-6">
                <Button
                    class="flex flex-row items-center justify-start w-full gap-3 text-xl font-medium"
                    variant="ghost"
                    href="/"
                    on:click={() => opened = false}
                >
                    <House size={24} />
                    Home
                </Button>

                <Button
                    class="flex flex-row items-center justify-start w-full gap-3 text-xl font-medium"
                    variant="ghost"
                    href="/reads"
                    on:click={() => opened = false}
                >
                    <TextAlignLeft size={24} />
                    Reads
                </Button>

                <Button
                    class="flex flex-row items-center justify-start w-full gap-3 text-xl font-medium"
                    variant="ghost"
                    href="/videos"
                    on:click={() => opened = false}
                >
                    <YoutubeLogo size={24} />
                    Watch
                </Button>

                <Button
                    class="flex flex-row items-center justify-start w-full gap-3 text-xl font-medium"
                    variant="ghost"
                    href="/chat"
                    on:click={() => opened = false}
                >
                    <CirclesFour size={24} />
                    Communities
                </Button>
                
                <Button
                    class="flex flex-row items-center justify-start w-full gap-3 text-xl font-medium !text-accent"
                    variant="ghost"
                    on:click={() => {
                        openModal(NewItemModal);
                        opened = false;
                    }}
                >
                    <PaperPlaneTilt size={24} />
                    Publish
                </Button>
            </div>

        <div class="grow"></div>
            <div class="flex flex-col gap-3">
                <div class="px-3">
                    <HorizontalOptionsList options={[
                        { component: { component: ToggleDark }, id: 'toggle' },
                        { icon: Door, fn: () => { logout(); opened = false; }, id: 'logout' }
                    ]} />
                </div>
                
                <Button
                    class="flex flex-row items-center justify-start w-full gap-3 text-xl font-medium"
                    variant="ghost"
                    href="/settings"
                    on:click={() => opened = false}
                >
                    <Gear size={24} />
                    Settings
                </Button>
            
                {#if $currentUser}
                    <UserProfile user={$currentUser} let:userProfile let:authorUrl>
                        <Button
                            class="flex flex-row items-center justify-start w-full gap-3 text-xl font-medium"
                            variant="ghost"
                            on:click={() => go(authorUrl)}>
                            <Avatar user={$currentUser} {userProfile} size="tiny" />
                            {userProfile?.name??""}
                        </Button>
                    </UserProfile>
                {/if}
            </div>
        </Block>
    </Page>
</Panel>