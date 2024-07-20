<script lang="ts">
	import LayoutHeader from "./LayoutHeader.svelte";
	import { layout } from "$stores/layout";
	import Modal from "./Modal.svelte";
	import { Toaster } from "$components/ui/sonner";
	import { appMobileView } from "$stores/app";
	import LayoutHeaderNavigation from "$components/Layout/Headers/LayoutHeaderNavigation.svelte";
	import DefaultHeader from "$components/Layout/Headers/DefaultHeader.svelte";
	import { history } from '$stores/history';
	import { ArrowDown, House } from "phosphor-svelte";
	import { goto } from "$app/navigation";
	import { fly, slide } from "svelte/transition";
    import Mobile from "./Mobile.svelte";
	import Wallet from "./Wallet.svelte";

    let withSidebar: boolean;

    $: withSidebar = $layout?.sidebar !== false;

    let startTouchY: number | undefined = undefined;
    let posY: number = 0;
    let scale: number = 1;
    let containerSaturation = 0;

    let appWrapper: HTMLDivElement;
    let mainContainer: HTMLDivElement;
    let historyContainer: HTMLDivElement;

    function headerTouchstart(event: TouchEvent) {
        event.preventDefault();

        startTouchY = event.touches[0].clientY;
    }

    let degreeOfGoingBackHome = 0;
    
    function headerTouchmove(event: TouchEvent) {
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
        scale = 1 - Math.min(0.15, Math.abs(diff) / 100);
        const opacity = 1 - Math.min(0.8, Math.abs(diff) / 200);
        
        appWrapper.style.transform = `translateY(${posY}px)`;
        // mainContainer.style.transform = `translateY(${posY}px) scale(${scale})`;
        mainContainer.style.opacity = opacity.toString();

        containerSaturation = Math.min(33, Math.abs(diff) * 2);
    }

    function gotoAndReset(url: string) {
        goto(url);
        resetView();
    }
    
    function resetView() {
        appWrapper.style.transition = "all";
        appWrapper.style.transitionDuration = "300ms";

        setTimeout(() => {
            appWrapper.style.transition = "";
        }, 300);
        
        appWrapper.style.transform = `translateY(0)`;
        mainContainer.style.opacity = "1";

        // renable scrolling in the body
        document.body.style.overflow = "auto";
        // renable clicks on main content
        mainContainer.style.pointerEvents = "auto";

        startTouchY = undefined;
        posY = 0;
        scale = 1;
    }

    function headerTouchend(e: TouchEvent) {
        console.log({posY, degreeOfGoingBackHome})
        
        if (posY >= 100) {
            if (degreeOfGoingBackHome >= 0.3) {
                setTimeout(() => goto("/"), 1);
            } else {
                return;
            }
        }

        if (posY < 5) {
            e.target.dispatchEvent(new MouseEvent('click', {
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
        if ($layout.navigation !== false && ($layout.header || $layout.title || $appMobileView)) {
            headerBarCount = 2;
        } else if ($layout.header === false) {
            headerBarCount = 0;
        } else {
            headerBarCount = 1;
        }
    }

    let mainClass = "";

    $: if (!$appMobileView ) {
        if ($layout.fullWidth === false) {
            mainClass = "lg:max-w-[var(--content-focused-width)] mx-auto lg:w-full lg:px-0 max-sm:w-screen w-full"
        } else if (withSidebar) {
            mainClass = "";
        } else {
            mainClass = "lg:max-w-[var(--content-focused-width)] mx-auto lg:w-full lg:px-0 max-sm:w-screen w-full";
        }
    }
</script>

<Mobile />

<!-- {#if showPromptForNotificiations}
            <PromptForNotifications on:done={() => showPromptForNotificiations = false} />
        {:else} -->

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div class="
    min-h-screen w-full
    max-lg:h-[90vw] z-50 overflow-clip
    transition-all duration-300
    {withSidebar ? "md:pl-[360px]" : ""}
" style={`
    background-color: rgba(${containerSaturation}, ${containerSaturation}, ${containerSaturation});
    transition: background-color 0.2s;
`} on:click={resetView}>
    {#if withSidebar}
        <div
            class="hidden border-r md:block fixed left-0 h-screen w-[360px]"
        >
            <div class="flex h-full max-h-screen flex-col gap-2">
                <div class="flex h-14 items-center border-b px-4 lg:h-[60px]">
                    <DefaultHeader />
                </div>
                <div class="flex-1 overflow-x-auto scrollbar-hide">
                    {#if $layout?.sidebar}
                        <svelte:component this={$layout.sidebar.component} {...$layout.sidebar.props} />
                    {/if}
                </div>
                <div class="mt-auto">
                    {#if $layout?.footer && !$layout.footerInMain}
                        <svelte:component this={$layout.footer.component} {...$layout.footer.props} />
                    {/if}
                </div>
            </div>
        </div>
    {/if}

    <div
        bind:this={appWrapper}
        class="
            flex flex-col z-1 mt-0-safe
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
                    class="bg-foreground/10 w-full flex flex-row items-center rounded-t-2xl text-center text-lg"
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

            <div class="flex flex-col items-center gap-2 py-10"
                style={`opacity: ${0.1+degreeOfGoingBackHome * 1.2}; transform: scale(${0.25 + degreeOfGoingBackHome})`}
            >
                <House size={48} weight="fill" class="text-muted-foreground" />

                <div class="text-lg">
                    Swipe down for Home
                </div>

                <ArrowDown size={24} class="text-muted-foreground" />
            </div>
        </div>
    
        <!-- Main content -->
        <div
            bind:this={mainContainer}
            class="flex flex-col bg-background z-50 h-screen overflow-y-auto"
        >
            {#if headerBarCount > 0}
                <!-- Header 1 -->
                <header transition:fly class="
                    mobile-nav
                    flex items-center fixed top-0 w-full
                    z-50
                    flex-col
                "
                    style={`height: '${60*headerBarCount}px'`}
                >
                    <div class="w-full border-b">
                        <div
                            class="
                                w-full h-[60px] responsive-padding flex flex-row
                            "
                            on:touchstart={headerTouchstart}
                            on:touchmove={headerTouchmove}
                            on:touchend={headerTouchend}
                        >
                            {#if $layout.header || $layout.title}
                                <LayoutHeader containerClass={$layout.sidebar === false ? mainClass : ""} />
                            {:else if $appMobileView}
                                <DefaultHeader />
                            {:else if $layout.navigation !== false}
                                <!-- If we are not showing a header, show the navigation bar -->
                                <LayoutHeaderNavigation class={mainClass} />
                            {/if}
                        </div>
                    </div>
                    <!-- Optional Navigation Bar (when there is a header) -->
                    {#if $layout.navigation !== false && ($layout.header || $layout.title || $appMobileView)}
                        <div class="w-full border-b">
                            <LayoutHeaderNavigation class={mainClass} />
                        </div>
                    {/if}
                </header>
                <div transition:slide class="flex-none" style={`height: ${60*headerBarCount}px`} />
            {/if}

            <main class="
                flex flex-1 flex-col gap-4 lg:gap-6
                overflow-x-clip
                {mainClass}
            ">
                <slot />
                <div class="mt-8-safe" style={`height: ${footerHeight}px`} />
                {#if $appMobileView || $layout.footerInMain}
                    {#if $layout.footer}
                        <footer class="fixed bottom-0 max-sm:bottom-6-safe w-full z-20 {mainClass} " bind:this={footerContainer}>
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