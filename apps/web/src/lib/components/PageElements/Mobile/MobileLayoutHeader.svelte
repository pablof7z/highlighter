<script lang="ts">
    import { goto } from '$app/navigation';
    import { pageHeader } from '$stores/layout.js';
	import Avatar from '$components/User/Avatar.svelte';
    import { Block, Icon, Link, Navbar, NavbarBackLink, Segmented, SegmentedButton, Toolbar } from 'konsta/svelte';
    import currentUser, { isGuest } from "$stores/currentUser";
	import HorizontalOptionsList from '$components/HorizontalOptionsList.svelte';
	import { MagnifyingGlass, User, UserCircle } from 'phosphor-svelte';
	import { openModal } from '$utils/modal';
	import SignupModal from '$modals/SignupModal.svelte';
	import UserDrawer from './UserDrawer.svelte';
	import { afterUpdate, onDestroy, onMount } from 'svelte';
    import TouchSweep from 'touchsweep';
	import { browser } from '$app/environment';

    let userPanelOpened = false;

    let title: string | undefined;
    let subtitle: string | undefined;

    let navbar: HTMLElement;

    const updateNavbarHeight = () => {
        if (!navbar) {
            document.documentElement.style.setProperty('--navbar-height', `0px`);
            return;
        }
        const navbarHeight = navbar.offsetHeight;
        document.documentElement.style.setProperty('--navbar-height', `${navbarHeight}px`);
    };

    onDestroy(() => {
        if (browser) window.removeEventListener('resize', updateNavbarHeight);
    });

    afterUpdate(() => {
        setTimeout(updateNavbarHeight);
    });

    $: {
        if (browser) updateNavbarHeight();
    }

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

    let mounted = false;
    let scrollingDown = false;
    let subNavbar: HTMLElement;
    let body: HTMLElement;

    function scrollUp() {
        // scale down the subnavbar
        body?.classList.remove('scrolldown')
        scrollingDown = false;

    }

    function scrollDown() {
        body?.classList.add('scrolldown')
        scrollingDown = true;
    }

    let instance: TouchSweep;

    onMount(() => {
        mounted = true
        body = document.getElementsByTagName('body')[0];
        // Initial update
        if (browser) updateNavbarHeight();

        // Update on window resize
        if (browser) window.addEventListener('resize', updateNavbarHeight);
        // instance = new TouchSweep(body,
        // { value: 1 }, 20 );
        // body.addEventListener('swipedown', (e) => {
        //     console.log(e.detail);
        //     scrollUp();
        // });

        // body.addEventListener('swipeup', (e) => {
        //     console.log(e.detail);
        //     scrollDown();
        // });

    });

    title ??= "";
    let _title = title;
    let subnavbarEl: HTMLElement;

    $: {
            if ($pageHeader?.subNavbarOptions?.length) {
            if (scrollingDown) {
                _title = $pageHeader.subNavbarOptions.find(option => option.value === $pageHeader.subNavbarValue)?.name ?? title!
                if (subnavbarEl) {
                    subnavbarEl.classList.add('-translate-y-full', 'opacity-0')
                    subnavbarEl.style.height = '0px';
                }
            } else {
                _title = title!;
                if (subnavbarEl) {
                    subnavbarEl.classList.remove('-translate-y-full', 'opacity-0')
                    subnavbarEl.style.height = 'auto';
                }
            }
            _title ??= "";
        }

        if ($pageHeader?.title) _title = $pageHeader?.title;
    }

    let withSubnavbar = false;

    $: withSubnavbar = !!(
        $pageHeader?.component ||
        ($pageHeader?.subNavbarOptions && $pageHeader?.subNavbarOptions.length > 0)
    );

    afterUpdate(() => {
        if (subNavbar && subNavbar.parentElement) {
            console.log(subNavbar);
            console.log(subNavbar.parentElement);
            subnavbarEl = subNavbar.parentElement;
            subnavbarEl.classList.add('transition-all', 'duration-300', 'overflow-y-hidden')
        }
    });
</script>

{#if mounted}
    {#if $pageHeader?.component}
        <svelte:component this={$pageHeader.component} {...$pageHeader.props} />
    {:else if withSubnavbar}
        <Navbar title={_title} {subtitle} bind:this={navbar} subnavbarClass="!px-0 responsive-scrollarea-padding">
            <svelte:fragment slot="left">
                {#if $pageHeader?.left}
                    {#if $pageHeader.left.component}
                        <svelte:component this={$pageHeader.left.component.component} {...$pageHeader.left.component.props} />
                    {:else if $pageHeader?.left?.url}
                        <NavbarBackLink
                            onClick={() => {
                                if ($pageHeader?.left?.url) {
                                    goto($pageHeader.left.url)
                                } else {
                                    window.history.back()
                                }
                            }}
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
                    <Link onClick={$pageHeader?.right?.fn}>
                        {#if $pageHeader?.right?.label}
                            {$pageHeader?.right?.label}
                        {/if}
                        <svelte:component this={$pageHeader.right.icon} class="w-6 h-6 mr-2 inline" />
                    </Link>
                {:else if $pageHeader?.searchBar}
                    <Link href="/search">
                        <MagnifyingGlass class="w-6 h-6" />
                    </Link>
                {/if}
            </svelte:fragment>

            <div slot="subnavbar" bind:this={subNavbar} class="flex flex-row items-end gap-0 overflow-y-hidden subnavbar scrollbar-hide">
                {#if $pageHeader?.component}
                    <svelte:component this={$pageHeader.component} {...$pageHeader.props} />
                {:else if $pageHeader?.subNavbarOptions}
                    <HorizontalOptionsList
                        options={$pageHeader.subNavbarOptions}
                        bind:value={$pageHeader.subNavbarValue}
                        class="py-2 responsive-padding {scrollingDown ? '' : ''}"
                    />
                {/if}
            </div>
        </Navbar>
    {:else}
        <Navbar title={_title} {subtitle}>
            <svelte:fragment slot="left">
                {#if $pageHeader?.left}
                    {#if $pageHeader.left.component}
                        <svelte:component this={$pageHeader.left.component.component} {...$pageHeader.left.component.props} />
                    {:else}
                        <NavbarBackLink
                            onClick={() => {
                                if ($pageHeader?.left?.url) {
                                    goto($pageHeader.left.url)
                                } else {
                                    window.history.back()
                                }
                            }}
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
    </Navbar>
    {/if}
{/if}

<UserDrawer bind:opened={userPanelOpened} />
