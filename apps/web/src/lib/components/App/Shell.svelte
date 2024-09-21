<script lang="ts">
	import LayoutHeader from "./LayoutHeader.svelte";
	import { headerTouchFns, layout, scrollPercentage } from "$stores/layout";
	import Modal from "./Modal.svelte";
	import { Toaster } from "$components/ui/sonner";
	import { appMobileView } from "$stores/app";
	import LayoutHeaderNavigation from "$components/Layout/Headers/LayoutHeaderNavigation.svelte";
	import DefaultHeader from "$components/Layout/Headers/DefaultHeader.svelte";
	import { history } from '$stores/history';
	import { ArrowDown, House } from "phosphor-svelte";
	import { goto, onNavigate } from "$app/navigation";
	import { fly, slide } from "svelte/transition";
    import Mobile from "./Mobile.svelte";
	import Wallet from "./Wallet.svelte";
	import { throttle } from "@sveu/shared";
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

    let startTouchY: number | undefined = undefined;
    let initialPosY = $appMobileView ? 5 : 0;
    let posY: number = initialPosY;
    let scale: number = 1;
    let containerSaturation = 0;

    let appWrapper: HTMLDivElement;
    let mainContainer: HTMLElement;
    let historyContainer: HTMLDivElement;
    let headerContainer: HTMLElement;

    let kHeight = 0;

    if (isMobileBuild()) {
        onMount(() => {
            Keyboard.addListener("keyboardWillHide", () => {
                kHeight = 0;
                document.documentElement.style.setProperty('--bottom-padding', 'var(--safe-area-inset-bottom)');
                mainContainer.style.setProperty('bottom-padding', '0');
            });
            
            Keyboard.addListener('keyboardWillShow', info => {
                const { keyboardHeight } = info;
                kHeight = keyboardHeight;

                // set in the root element the variable --bottom-padding to the keyboard height
                document.documentElement.style.setProperty('--bottom-padding', `${keyboardHeight}px`);
            });
        });
    } else {
        document.documentElement.style.setProperty('--bottom-padding', 'var(--safe-area-inset-bottom)');
    }

    function headerTouchstart(event: TouchEvent) {
        // check if the target, or any of its parents, has the attribute data-header-shell-ignore
        let target = event.target as HTMLElement;
        while (target) {
            if (target.hasAttribute("data-header-shell-ignore")) {
                headerMoveIgnore = true;
                return;
            }
            target = target.parentElement;
        }
        startTouchY = event.touches[0].clientY;
    }

    let degreeOfGoingBackHome = 0;
    let headerMoveIgnore = false;

    function headerTouchmove(event: TouchEvent) {
        // if it has the attribute data-header-shell-ignore, ignore the touch event
        if (headerMoveIgnore) return;
        if (startTouchY === undefined) return;

        const touchY = event.touches[0].clientY;
        const diff = touchY - startTouchY;

        if (diff < 10) {
            return;
        }

        // disable scrolling in the body
        document.body.style.overflow = "hidden";

        // disable clicks on main content
        mainContainer.style.pointerEvents = "none";

        event.preventDefault();
        
        const viewportHeight = window.innerHeight * 0.5;

        // after diff is half of viewportHeight, start setting degreeOfGoingBackHome so that when it reaches 100 it's 1
        const diffAfterHalfOfViewport = Math.max(0, diff - viewportHeight / 2);
        degreeOfGoingBackHome = Math.min(1, diffAfterHalfOfViewport / viewportHeight);

        posY = Math.min(viewportHeight, diff);
        scale = 1;// - Math.min(0.15, Math.abs(diff) / 10000);
        const opacity = 1 - Math.min(0.8, Math.abs(diff) / 200);
        
        appWrapper.style.transform = `translateY(${posY}px)`;
        mainContainer.style.transform = `scale(${scale})`;
        mainContainer.style.opacity = opacity.toString();

        containerSaturation = Math.min(33, Math.abs(diff) * 2);
    }

    $headerTouchFns = {
        start: headerTouchstart,
        move: headerTouchmove,
        end: headerTouchend
    };

    function gotoAndReset(url: string) {
        goto(url);
        resetView();
    }

    function setForceHeaderOpacity() {
        forceHeaderOpacity = true;
        headerContainer.style.opacity = "1";
        setTimeout(() => {
            forceHeaderOpacity = false;
        }, 10000);
    }
    
    function resetView() {
        appWrapper.style.transition = "all";
        appWrapper.style.transitionDuration = "300ms";
        mainContainer.style.transition = "all";
        mainContainer.style.transitionDuration = "300ms";

        setTimeout(() => {
            appWrapper.style.transition = "";
            mainContainer.style.transition = "";
        }, 300);
        
        appWrapper.style.transform = `translateY(${initialPosY}px) scale(1)`;
        mainContainer.style.opacity = "1";
        mainContainer.style.transform = ``;

        // renable scrolling in the body
        document.body.style.overflow = "auto";
        // renable clicks on main content
        mainContainer.style.pointerEvents = "auto";

        startTouchY = undefined;
        posY = initialPosY;
        scale = 1;
    }

    function headerTouchend(e: TouchEvent) {
        if (headerMoveIgnore) {
            headerMoveIgnore = false;
            return;
        }
        
        headerMoveIgnore = false;

        if (posY >= 100) {
            if (degreeOfGoingBackHome >= 0.3) {
                setTimeout(() => goto("/"), 1);
            } else {
                return;
            }
        }

        if (posY < 5) {
            e.target?.dispatchEvent(new MouseEvent('click', {
                view: window,
                bubbles: true,
                cancelable: true
            }));
        }

        resetView();
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
    let forceHeaderOpacity = false;

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

        // if (headerContainer) {
        //     let opacity = 1;
        //     if (!forceHeaderOpacity && $layout.event && $layout.headerCanBeTransparent !== false) {
        //         if (scrollDir === "down") {
        //             if ($scrollPercentage > 10) {
        //                 opacity = 1 - ($scrollPercentage - 10) / 10;
        //             }
        //             if (opacity < 0.25) opacity = 0.25;
        //         }
        //     }
        //     headerContainer.style.opacity = opacity.toString();
        // }

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
    
    const mainScroll = throttle(onScroll, 0.2);

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
    let mainLeftPadding = 0;
</script>

<!-- <div class="fixed top-52 left-2 bg-red-500 p-4 z-[9999999]">
    {bottomPadding}
</div> -->

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

        <main
            bind:this={mainContainer}
        >
            <div class="
                {mainClass}
            ">
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
        

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->


<Modal />

<Toaster />

<Wallet />
