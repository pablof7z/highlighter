<script lang="ts">
	import { layout, pageHeader } from "$stores/layout";
	import HeaderLeftButton from "./HeaderLeftButton.svelte";
	import HeaderRightButton from "./HeaderRightButton.svelte";
    import * as Event from "$components/Event";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { page } from "$app/stores";
	import HomeButton from "./HomeButton.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import Avatar from '$components/User/Avatar.svelte';
	import UserProfile from '$components/User/UserProfile.svelte';
	import { goto } from "$app/navigation";
	import { Button } from "$components/ui/button";
	import { fade } from "svelte/transition";
	import { CaretDown } from "phosphor-svelte";

    export let containerClass: string = "";
    export let scrollDir: 'up' | 'down' | undefined;
</script>

<div class="flex flex-row justify-between items-center h-full w-full gap-2 pt-[var(--safe-area-inset-top)]">
    {#if $layout.header?.component}
        <div class="w-full h-full flex flex-col">
            <svelte:component
                this={$layout.header.component}
                {...$layout.header.props}
                class={$$props.containerClass}
            />

            {#if $pageHeader?.subNavbarOptions}
                <div class="py-2 {$$props.containerClass??""}">
                    <HorizontalOptionsList
                        options={$pageHeader.subNavbarOptions}
                        containerClass={$$props.containerClass}
                        bind:value={$pageHeader.subNavbarValue}
                    />
                </div>
            {/if}
        </div>
    {:else}
        <div class="flex flex-row items-stretch w-full">
            {#if $layout.sidebar === false}
                {#if $page.url.pathname !== "/"}
                    <div class="fixed max-sm:hidden ml-2">
                        <HomeButton />
                    </div>
                {/if}
            {/if}
            
            <div class="flex items-center justify-between max-w-[var(--content-focused-width)] mx-auto w-full {containerClass}">
                <div class="flex flex-row gap-3 items-center w-full truncate">
                    <HeaderLeftButton />

                    {#if $layout?.iconUrl}
                        <!-- svelte-ignore a11y-missing-attribute -->
                        <img src={$layout.iconUrl} class="w-8 h-8 rounded-full flex-none" />
                    {:else if $layout.event}
                        <UserProfile user={$layout.event.author} let:userProfile let:authorUrl>
                            <a href={authorUrl} class="flex-none">
                                <Avatar {userProfile} pubkey={$layout.event.pubkey} class="w-8 h-8" />
                            </a>
                        </UserProfile>
                    {/if}

                    {#if $layout?.title}
                        <div class="
                            flex flex-row
                            text-foreground
                            font-bold text-xl
                            gap-2
                            col-span-5
                            text-center
                            grow truncate
                        ">
                            <span class="truncate">{$layout?.title}</span>
                        </div>
                    {/if}
                </div>

                {#if $layout.navigation && (scrollDir === 'down')}
                    <div in:fade>
                        <Button variant="accent" on:click={() => $layout.forceShowNavigation = !$layout.forceShowNavigation}>
                            {#if ($layout.activeOption||$layout.navigation[0]).icon}
                                <svelte:component
                                    this={($layout.activeOption||$layout.navigation[0]).icon}
                                    class="w-6 h-6 mr-2"
                                    {...($layout.activeOption||$layout.navigation[0]).iconProps}
                                />
                            {/if}
                            {#if ($layout.activeOption||$layout.navigation[0]).name}
                                {($layout.activeOption||$layout.navigation[0]).name}
                            {/if}
                            <CaretDown size={16} class="ml-2" />
                        </Button>
                    </div>
                {:else if $layout.event}
                    <RelativeTime event={$layout.event} class="text-muted-foreground !text-sm ml-4 whitespace-nowrap" />
                    <Event.Dropdown
                        event={$layout.event}
                        on:delete={() => goto('/')}
                        on:delete:cancel={(e) => goto('/a/'+e.detail?.event?.encode())}
                    />
                {/if}

                {#if $layout?.options}
                    <HeaderRightButton />
                {/if}
            </div>
        </div>
    {/if}
</div>