<script lang="ts">
    import { goto } from '$app/navigation';
    import { pageHeader, pageNavigationOptions } from '$stores/layout';
	import { Avatar } from '@kind0/ui-common';
    import { Block, Icon, Link, Navbar, NavbarBackLink, Segmented, SegmentedButton } from 'konsta/svelte';
    import currentUser, { isGuest } from "$stores/currentUser";
	import HorizontalOptionsList from '$components/HorizontalOptionsList.svelte';
	import { MagnifyingGlass, User, UserCircle } from 'phosphor-svelte';
	import { openModal } from '$utils/modal';
	import SignupModal from '$modals/SignupModal.svelte';
	import UserDrawer from './UserDrawer.svelte';
	import SearchModal from '$modals/SearchModal.svelte';

    let userPanelOpened = false;

    let title: string | undefined;
    let subtitle: string | undefined;

    $: {
        title = $pageHeader?.title;
        subtitle = $pageHeader?.subtitle;

        if (title && title.length > 20) {
            // if we have no subtitle, break the title into two lines at a whitespace between the
            // 15th and 25th character (wherever the whitespace is)
            // if there is no whitespace, break at 20 characters and don't use the subtitle
            let breakIndex = subtitle ? 25 : title.indexOf(' ', 15);
            if (breakIndex === -1) {
                title = `${title.slice(0, 25)}...`;
            } else if (breakIndex > 25) {
                breakIndex = 25;
            }

            if (breakIndex > 0)
                title = `${title.slice(0, breakIndex)}`;

            if (!subtitle || subtitle.length === 0) {
                subtitle = $pageHeader!.title!.slice(breakIndex, breakIndex + 509);
            }
        }
    }

    $: title ??= "Highlighter";

    let withSubnavbar = false;

    $: withSubnavbar = !!($pageHeader?.component || $pageNavigationOptions?.length > 0);
</script>

{#if withSubnavbar}
    <Navbar title={title??"Highlighter"} {subtitle} id="navbar">
        <svelte:fragment slot="left">
            {#if $pageHeader?.left}
                {#if $pageHeader.left.component}
                    <svelte:component this={$pageHeader.left.component.component} {...$pageHeader.left.component.props} />
                {:else if $pageHeader?.left?.url}
                    <NavbarBackLink
                        onClick={() => goto($pageHeader.left.url)}
                    />
                {/if}
            {:else}
                {#if $currentUser}
                    <Link onClick={() => userPanelOpened = true}>
                        <Avatar user={$currentUser} size="small" class="flex-none" />
                    </Link>
                {:else}
                    <Link onClick={() => openModal(SignupModal)}>
                        <UserCircle class="w-6 h-6 mr-2" />
                        Login
                    </Link>
                {/if}
            {/if}
        </svelte:fragment>

        <svelte:fragment slot="right">
            {#if $pageHeader?.right}
                <Link onClick={$pageHeader.right.fn}>
                    {#if $pageHeader.right.label}
                        {$pageHeader.right.label}
                    {/if}
                    <svelte:component this={$pageHeader.right.icon} class="w-6 h-6 mr-2 inline" />
                </Link>
            {:else if $pageHeader?.searchBar}
                <Link href="/search">
                    <MagnifyingGlass class="w-6 h-6" />
                </Link>
            {/if}
        </svelte:fragment>

        <svelte:fragment slot="subnavbar">
            {#if $pageHeader?.component}
                <svelte:component this={$pageHeader.component} {...$pageHeader.props} />
            {:else if $pageNavigationOptions && $pageNavigationOptions.length > 0}
                <HorizontalOptionsList options={$pageNavigationOptions} />
            {/if}
        </svelte:fragment>
    </Navbar>
{:else}
    <Navbar title={title??"Highlighter"} {subtitle} id="navbar">
        <svelte:fragment slot="left">
            {#if $pageHeader?.left}
                {#if $pageHeader.left.component}
                    <svelte:component this={$pageHeader.left.component.component} {...$pageHeader.left.component.props} />
                {:else if $pageHeader?.left?.url}
                    <NavbarBackLink
                        onClick={() => goto($pageHeader.left.url)}
                    />
                {/if}
            {:else}
                {#if $currentUser}
                    <Link onClick={() => userPanelOpened = true}>
                        <Avatar user={$currentUser} size="small" class="flex-none" />
                    </Link>
                {:else}
                    <Link onClick={() => openModal(SignupModal)}>
                        <UserCircle class="w-6 h-6 mr-2" />
                        Login
                    </Link>
                {/if}
            {/if}
        </svelte:fragment>

        <svelte:fragment slot="right">
            {#if $pageHeader?.right}
                <Link onClick={$pageHeader.right.fn}>
                    {$pageHeader.right.label}
                    <svelte:component this={$pageHeader.right.icon} class="w-6 h-6 mr-2 inline" />
                </Link>
            {:else if $pageHeader?.searchBar}
                <Link href="/search">
                    <MagnifyingGlass class="w-6 h-6" />
                </Link>
            {/if}
        </svelte:fragment>
</Navbar>
{/if}

<UserDrawer bind:opened={userPanelOpened} />