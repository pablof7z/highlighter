<script lang="ts">
	import LayoutHeader from "./LayoutHeader.svelte";
	import { layout, scrollPercentage } from "$stores/layout";
	import Modal from "./Modal.svelte";
	import { Toaster } from "$components/ui/sonner";
	import { appMobileView } from "$stores/app";
	import { onNavigate } from "$app/navigation";
	import { fly } from "svelte/transition";
    import Mobile from "./Mobile.svelte";
	import Wallet from "./Wallet.svelte";
    import { Keyboard } from '@capacitor/keyboard';
	import { isMobileBuild } from '$utils/view/mobile';
	import { onMount } from "svelte";
	import DesktopColumnNavigation from "./DesktopColumnNavigation.svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { ScrollArea } from "$components/ui/scroll-area";

    onNavigate(() => {
		mainContainer.scrollTop = 0;
	})

    let withSidebar: boolean;

    $: withSidebar = false //$layout?.sidebar !== false;

    let mainContainer: HTMLElement;
    let headerContainer: HTMLElement;

    if (isMobileBuild()) {
        onMount(() => {
            Keyboard.addListener("keyboardWillHide", () => {
                document.documentElement.style.setProperty('--bottom-padding', 'var(--safe-area-inset-bottom)');
                mainContainer.style.setProperty('bottom-padding', '0');
            });
            
            Keyboard.addListener('keyboardWillShow', info => {
                const { keyboardHeight } = info;
                // set in the root element the variable --bottom-padding to the keyboard height
                document.documentElement.style.setProperty('--bottom-padding', `${keyboardHeight}px`);
            });
        });
    } else {
        document.documentElement.style.setProperty('--bottom-padding', 'var(--safe-area-inset-bottom)');
    }

    let footerContainer: HTMLElement | undefined;
    let footerHeight: number = 0;

    $: if ($layout.footer) {
        footerHeight = footerContainer?.offsetHeight || 0;
    }

    let headerBarCount = 1;

    $: {
        if ($layout.header !== false) {
            if ($layout.navigation !== false && ($layout.header || $layout.title || $appMobileView)) {
                headerBarCount = 2;
            } else {
                headerBarCount = 1;
            }
        } else {
            headerBarCount = 0;
        }
    }

    let mainClass = "";

    $: if (!$appMobileView ) {
        if ($layout.fullWidth === true) {
            mainClass = "";
        } else if (withSidebar) {
            mainClass = "lg:max-w-[var(--content-focused-width)] mx-auto lg:w-full lg:px-0 max-sm:w-screen w-full"
        } else if ($layout.fullWidth === false) {
            mainClass = "lg:max-w-[var(--content-focused-width)] mx-auto lg:w-full lg:px-0 max-sm:w-screen w-full"
        }
    }

    let scrollDir: "up" | "down" | undefined;

    function markScrollingDirection(e: Event) {
        if (!e.target) return;
        
        const { scrollTop, scrollHeight, clientHeight } = e.target as HTMLElement;

        const isAtTop = scrollTop === 0;
        const isAtBottom = scrollTop + clientHeight >= scrollHeight;

        currentY = scrollTop;
        $scrollPercentage = (currentY / (scrollHeight - clientHeight)) * 100;

        if (isAtBottom) {
            $scrollPercentage = 100;
        } else if (isAtTop) {
            $scrollPercentage = 0;
        }

        if (currentY > prevY && currentY > 50) {
            scrollDir = "down";
        } else if (currentY < prevY - 10) {
            scrollDir = "up";
            if (isMobileBuild()) try { Keyboard.hide(); } catch {}
        }

        prevY = currentY;
    }

    $scrollPercentage = 0;

    onMount(() => {
        updateHeaderSize();
    })

    function onScroll(e: Event) {
        markScrollingDirection(e);
        setTimeout(updateHeaderSize, 50);
    }

    onMount(() => {
        setTimeout(updateHeaderSize, 50);
    });

    function updateHeaderSize() {
        const headerHeight = headerContainer?.clientHeight || 0;
        document?.documentElement.style.setProperty('--header-height', `${headerHeight+1}px`);
        document?.documentElement.style.setProperty('--header-height', `${headerHeight+1}px`);
    }
    
    let currentY = 0;
    let prevY = 0;

    let bottomPadding = "0";

    setInterval(() => {
        // get css variable bottom-padding
        bottomPadding = document.documentElement.style.getPropertyValue('--footer-height');
    }, 1000)

    let hasNavSidebar: boolean;

    $: hasNavSidebar = $layout.navSidebar !== false;
    
    let collapseNavOptions = false;
</script>

<Mobile />

<!-- {#if showPromptForNotificiations}
            <PromptForNotifications on:done={() => showPromptForNotificiations = false} />
        {:else} -->

<div data-vaul-drawer-wrapper>
    {#if hasNavSidebar}
        <div class="hidden lg:fixed lg:inset-y-0 lg:left-0 lg:z-50 lg:block lg:w-[var(--app-shell-left-nav-width)] lg:overflow-y-auto border-r border-border lg:pb-4" transition:fly>
            <DesktopColumnNavigation />
        </div>
    {/if}

    <div class="{hasNavSidebar ? 'lg:pl-[var(--app-shell-left-nav-width)]' : ''}">
        <div class="sticky top-0 max-sm:top-0-safe z-40 flex flex-col mobile-nav">
            {#if $layout.title && $layout.header !== false}
                <div class=" flex h-16 shrink-0 items-center gap-x-4 border-b shadow-sm sm:gap-x-6">
                    <LayoutHeader bind:collapseNavOptions scrollPercentage={$scrollPercentage} {scrollDir} />
                </div>
            {/if}

            {#if $layout.navigation}
                <div class="flex h-auto shrink-0 items-center gap-x-4 border-b shadow-sm sm:gap-x-6">
                    <ScrollArea class="py-1 lg:py-1.5 lg:px-4 whitespace-nowrap {$$props.class??""}" orientation="horizontal">
                        <HorizontalOptionsList
                            options={$layout.navigation}
                            bind:activeOption={$layout.activeOption}
                            on:changed={() => {
                                $layout.forceShowNavigation = false;
                            }}
                        />
                    </ScrollArea>
                </div>
            {/if}
        </div>

        <main bind:this={mainContainer}>
            <div class="{mainClass}">
                <slot />
            </div>

            <div class="h-24 w-full"></div>

            <footer
                class="fixed bottom-0 max-sm:bottom-0-safe left-0 lg:pl-[var(--app-shell-left-nav-width)] right-0 z-20 w-full border-t border-border mobile-nav"
                bind:this={footerContainer}
            >
                {#if $layout.footer}
                    <svelte:component this={$layout.footer.component} {...$layout.footer.props} />
                {/if}
            </footer>
            
        </main>
    </div>
</div>

<Modal />

<Toaster />

<Wallet />
