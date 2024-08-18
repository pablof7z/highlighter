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

    onNavigate(() => {
		mainContainer.scrollTop = 0;
	})

    let withSidebar: boolean;

    $: withSidebar = $layout?.sidebar !== false;

    let startTouchY: number | undefined = undefined;
    let initialPosY = $appMobileView ? 5 : 0;
    let posY: number = initialPosY;
    let scale: number = 1;
    let containerSaturation = 0;

    let appWrapper: HTMLDivElement;
    let mainContainer: HTMLDivElement;
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

        if (headerContainer) {
            let opacity = 1;
            if (!forceHeaderOpacity && $layout.event && $layout.headerCanBeTransparent !== false) {
                if (scrollDir === "down") {
                    if ($scrollPercentage > 10) {
                        opacity = 1 - ($scrollPercentage - 10) / 10;
                    }
                    if (opacity < 0.25) opacity = 0.25;
                }
            }
            headerContainer.style.opacity = opacity.toString();
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
    
    const mainScroll = throttle(onScroll, 0.2);

    let currentY = 0;
    let prevY = 0;

    let bottomPadding = "0";

    setInterval(() => {
        // get css variable bottom-padding
        bottomPadding = document.documentElement.style.getPropertyValue('--footer-height');
    }, 1000)

</script>

<!-- <div class="fixed top-52 left-2 bg-red-500 p-4 z-[9999999]">
    {bottomPadding}
</div> -->

<Mobile />

<!-- {#if showPromptForNotificiations}
            <PromptForNotifications on:done={() => showPromptForNotificiations = false} />
        {:else} -->

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div class="
    w-full bg-muted-foreground
    max-sm:h-screen
    max-lg:h-[90vw] z-50
    transition-all duration-300
    {withSidebar ? "md:pl-[360px]" : ""}
" style={`
`} on:click={resetView} data-vaul-drawer-wrapper>
    {#if withSidebar}
        <div
            class="hidden border-r md:block fixed left-0 h-screen w-[360px] bg-background"
        >
            <div class="flex h-full max-h-screen flex-col">
                <div class="flex h-14 items-center border-b px-4 lg:h-[60px]">
                    <DefaultHeader />
                </div>
                <div class="flex-1 overflow-x-auto scrollbar-hide">
                    {#if $layout?.sidebar}
                        <svelte:component this={$layout.sidebar.component} {...$layout.sidebar.props} />
                    {/if}
                </div>
            </div>
        </div>
    {/if}

    <div
        bind:this={appWrapper}
        style="transform: translateY({initialPosY}px)"
        class="
            flex flex-col z-1
            translate-y-0
        "
    >
        <div
            class="w-full items-center flex flex-col-reverse -translate-y-full fixed top-0"
            bind:this={historyContainer}
            on:click={resetView}
        >
            {#each $history as history, i}
                <button
                    class="bg-background/50 w-full flex flex-row items-center rounded-t-2xl text-center text-lg"
                    class:justify-center={!history.category}
                    style={`max-width: ${100 - (i+1) * 10}%; opacity: ${1 - (i+1) * 0.2}`}
                    on:click={() => gotoAndReset(history.url)}
                >
                    <div class="p-4 truncate">
                        {#if history.category}
                            <span class="text-muted-foreground mr-2">{history.category}</span>
                        {/if}
                        {history.title}
                    </div>
                    
                </button>
            {/each}

            <div class="flex flex-col items-center gap-2 py-10 text-background"
                style={`opacity: ${0.1+degreeOfGoingBackHome * 2}; transform: scale(${0.5 + degreeOfGoingBackHome})`}
            >
                <House size={48} weight="fill" />

                <div class="text-lg">
                    Swipe down for Home
                </div>

                <ArrowDown size={24} />
            </div>
        </div>
    
        <!-- Main content -->
        <div
            bind:this={mainContainer}
            class="
                max-sm:rounded-t-3xl
                flex flex-col bg-background z-50 overflow-y-auto scrollbar-hide
                pb-[calc(var(--bottom-padding)+var(--footer-height))]
            " style="height: calc(100vh - {posY}px)"
            on:scroll={mainScroll}
        >
            {#if headerBarCount > 0}
                <!-- Header 1 -->
                <header transition:fly class="
                    mobile-nav max-sm:rounded-t-3xl overflow-y-clip
                    flex items-center fixed top-0 w-full
                    border-b border-border
                    z-50
                    flex-col
                " bind:this={headerContainer}
                    on:click={setForceHeaderOpacity}
                >
                    <div class="w-full">
                        <div
                            class="
                                w-full responsive-padding flex flex-row items-center
                                pt-[calc(var(--safe-area-inset-top))] 
                            "
                            on:touchstart|passive={headerTouchstart}
                            on:touchmove|passive={headerTouchmove}
                            on:touchend|passive={headerTouchend}
                        >
                            {#if $layout.header || $layout.title}
                                <LayoutHeader scrollPercentage={$scrollPercentage} {scrollDir} containerClass={$layout.sidebar === false ? mainClass : ""} />
                            {:else if $appMobileView}
                                <DefaultHeader />
                            {:else if $layout.navigation !== false}
                                <!-- If we are not showing a header, show the navigation bar -->
                                <LayoutHeaderNavigation {scrollDir} class={mainClass} />
                            {/if}
                        </div>
                    </div>
                    <!-- Optional Navigation Bar (when there is a header) -->
                    {#if $layout.navigation !== false && ($layout.header || $layout.title || $appMobileView)}
                        <div class="w-full">
                            <LayoutHeaderNavigation {scrollDir} class={mainClass} />
                        </div>
                    {/if}
                </header>
                <div transition:slide class="flex-none pt-[var(--safe-area-inset-top)] h-[var(--header-height)]" />
            {/if}

            <main class="
                flex flex-1 flex-col lg:gap-6
                overflow-x-clip
                pb-[var(--footer-height)]
                {mainClass}
            ">
                <slot />
                <div class="mt-8-safe" style={`height: ${footerHeight}px`} />
                {#if $appMobileView || $layout.footerInMain}
                    {#if $layout.footer}
                        <footer
                            class="mobile-nav fixed bottom-0 left-0 border-t border-border right-0 max-sm:bottom-0-safe w-full z-20
                            transition-all duration-300
                            "
                        >
                            <svelte:component this={$layout.footer.component} {...$layout.footer.props} />
                        </footer>
                    {/if}
                {/if}
            </main>
        </div>
    </div>
</div>

<Modal />

<Toaster />

<Wallet />