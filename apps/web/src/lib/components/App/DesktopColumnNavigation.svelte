<script lang="ts">
	import WalletConnect from '$modals/WalletConnect';
    import { Inbox, Bell, Highlighter } from 'lucide-svelte';
	import { Button } from "$components/ui/button";
	import LogoSmall from "$icons/LogoSmall.svelte";
    import { toggleMode } from "mode-watcher";
	import { Gear, Plus, PresentationChart, BookmarkSimple, Wallet, Moon, Tray, House } from "phosphor-svelte";
    import * as Tooltip from "$lib/components/ui/tooltip";
	import CurrentUser from "$components/CurrentUser.svelte";
	import NewItemButton from "$views/Home/Main/NewItemButton.svelte";
	import { page } from "$app/stores";
	import Separator from "$components/ui/separator/separator.svelte";
	import { getEventUrl } from "$utils/url";
	import { derived } from "svelte/store";
	import { userArticleCurations } from "$stores/session";
	import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
	import { openModal } from '$utils/modal';

    let activeHighlights: boolean;

    $: activeHighlights = $page.url.pathname.startsWith("/highlights");

    const saveForLaterCuration = derived(userArticleCurations, $userArticleCurations => {
        return Array.from($userArticleCurations.values()).find(c => c.dTag === 'saved')
    });

    let activeItem: string;

    $: {
        const url = $page.url.pathname;

        if ($saveForLaterCuration && getEventUrl($saveForLaterCuration).endsWith(url)) {
            activeItem = '/bookmarks';
        } else {
            activeItem = url;
        }
    }
</script>

<div class="flex flex-col justify-between h-full items-center py-2">
    <LogoSmall class="w-10 h-10" />
    <nav class="flex flex-col items-center gap-2">
        <Tooltip.Root openDelay={0}>
            <Tooltip.Trigger>
                <Button variant={activeItem === '/' ? "secondary" : "ghost"} class="w-12 h-12 p-2" href="/">
                    <House
                        size={32}
                    />
                </Button>
            </Tooltip.Trigger>
            <Tooltip.Content side="right">
                Home
            </Tooltip.Content>
        </Tooltip.Root>

        <Tooltip.Root openDelay={0}>
            <Tooltip.Trigger>
                <Button variant={activeItem === '/highlights' ? 'secondary' : 'ghost' } class="w-12 h-12 p-2 {activeHighlights ? 'active' : ''}" href="/highlights">
                    <LogoSmall class="w-8 h-8" />
                </Button>
            </Tooltip.Trigger>
            <Tooltip.Content side="right">
                Highlights
            </Tooltip.Content>
        </Tooltip.Root>
        
        <!-- <Tooltip.Root openDelay={0}>
            <Tooltip.Trigger>
                <Button variant={activeItem === '/inbox' ? "secondary" : "ghost"} class="w-12 h-12 p-2" href="/inbox">
                    <Inbox
                        size={32}
                    />
                </Button>
            </Tooltip.Trigger>
            <Tooltip.Content side="right">
                Inbox
            </Tooltip.Content>
        </Tooltip.Root> -->

        <Tooltip.Root openDelay={0}>
            <Tooltip.Trigger>
                <Button variant={activeItem === '/notifications' ? "secondary" : "ghost"} class="w-12 h-12 p-2" href="/notifications">
                    <Bell
                        size={32}
                        weight={activeItem === '/notifications' ? 'fill' : 'regular'}
                    />
                </Button>
            </Tooltip.Trigger>
            <Tooltip.Content side="right">
                Notifications
            </Tooltip.Content>
        </Tooltip.Root>

        {#if $saveForLaterCuration}
            <Tooltip.Root openDelay={0}>
                <Tooltip.Trigger>
                    <Button variant={activeItem === '/bookmarks' ? "secondary" : "ghost"} class="w-12 h-12 p-2" href={getEventUrl($saveForLaterCuration)}>
                        <BookmarkSimple size={32} weight={activeItem === '/bookmarks' ? 'fill' : 'regular'} />
                    </Button>
                </Tooltip.Trigger>
                <Tooltip.Content side="right">
                    Bookmarks
                </Tooltip.Content>
            </Tooltip.Root>
        {/if}

        <Separator />

        <Tooltip.Root openDelay={0}>
            <Tooltip.Trigger>
                <Button variant={activeItem === '/studio' ? "secondary" : "ghost"} class="w-12 h-12 p-2" href="/studio">
                    <PresentationChart size={32} weight={activeItem === '/studio' ? 'fill' : 'regular'} />
                </Button>
            </Tooltip.Trigger>
            <Tooltip.Content side="right">
                Studio
            </Tooltip.Content>
        </Tooltip.Root>
        
        <Tooltip.Root openDelay={0}>
            <Tooltip.Trigger>
                <NewItemButton>
                    <Button class="w-12 h-12 p-2" variant="accent">
                        <Plus size={32} weight="bold" />
                    </Button>
                </NewItemButton>
            </Tooltip.Trigger>
            <Tooltip.Content side="right">
                Create
            </Tooltip.Content>
        </Tooltip.Root>
    </nav>


    <div class="flex flex-col items-center gap-4">
        <DropdownMenu.Root>
            <DropdownMenu.Trigger>
                <Button variant="ghost" class="w-12 h-12 p-2">
                    <Gear size={32} weight="regular" />
                </Button>
            </DropdownMenu.Trigger>
            <DropdownMenu.Content>
                <DropdownMenu.Item href="/settings">
                    <Gear size={20} weight="bold" class="mr-3" />
                    Settings
                </DropdownMenu.Item>
                <DropdownMenu.Item on:click={() => openModal(WalletConnect)}>
                    <Wallet size={20} weight="bold" class="mr-3" />
                    Connect Wallet
                </DropdownMenu.Item>

                <DropdownMenu.Separator />

                <DropdownMenu.Item on:click={toggleMode}>
                    <Moon size={20} weight="bold" class="mr-3" />
                    Toggle Dark Mode
                </DropdownMenu.Item>
                
            </DropdownMenu.Content>
        </DropdownMenu.Root>
        <!-- <ToggleDark variant="ghost" /> -->
        
        <CurrentUser />
    </div>
</div>

<style lang="postcss">
    
</style>