<script lang="ts">
	import { layout, pageHeader } from "$stores/layout";
	import { afterUpdate, onDestroy, onMount } from "svelte";
	import HeaderLeftButton from "./HeaderLeftButton.svelte";
	import HeaderRightButton from "./HeaderRightButton.svelte";
    import * as Event from "$components/Event";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { browser } from "$app/environment";
	import { page } from "$app/stores";
	import HomeButton from "./HomeButton.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import Avatar from '$components/User/Avatar.svelte';
	import UserProfile from '$components/User/UserProfile.svelte';
	import { goto } from "$app/navigation";

    export let containerClass: string = "";

    let render = false;
    let navbar: HTMLElement;

    const updateNavbarHeight = () => {
        if (!navbar) {
            document.documentElement.style.setProperty('--navbar-height', `0px`);
            return;
        }
        setTimeout(() => {
            const navbarHeight = navbar.offsetHeight;
            document.documentElement.style.setProperty('--navbar-height', `${navbarHeight}px`);
        }, 10)
    };

    onMount(() => {
        // Initial update
        if (browser) updateNavbarHeight();

        // Update on window resize
        if (browser) window.addEventListener('resize', updateNavbarHeight);
    });

    onDestroy(() => {
        if (browser) window.removeEventListener('resize', updateNavbarHeight);
    });

    afterUpdate(() => {
        setTimeout(updateNavbarHeight);
    });

    $: {
        if (browser) updateNavbarHeight();
        render = render;
    }
</script>

<div class="
w-full
" bind:this={navbar}>
    <div class="flex flex-row justify-between items-center h-full w-full gap-2 py-3">
        {#if $layout.header?.component}
            <div class="w-full h-full flex flex-col">
                <svelte:component
                    this={$layout.header.component}
                    {...$layout.header.props}
                    class={$$props.containerClass}
                    on:resize={updateNavbarHeight}
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

                    {#if $layout.event}
                        <RelativeTime event={$layout.event} class="text-muted-foreground text-sm ml-4" />
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
</div>