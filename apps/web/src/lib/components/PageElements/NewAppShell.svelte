<script lang="ts">
	import LayoutHeader from "./AppShell/LayoutHeader.svelte";
	import { layout } from "$stores/layout";
	import WalletState from "$components/Layout/Headers/WalletState.svelte";
	import Modal from "./Modal.svelte";
	import { Toaster } from "$components/ui/sonner";
	import { appMobileView } from "$stores/app";
	import LayoutHeaderNavigation from "$components/Layout/Headers/LayoutHeaderNavigation.svelte";

    let withSidebar: boolean;

    $: withSidebar = $layout?.sidebar !== false;
</script>

<div class="
    grid min-h-screen w-full
    {withSidebar ? "md:pl-[360px]" : ""}
">
    {#if withSidebar}
        <div class="hidden border-r md:block fixed left-0 h-screen w-[360px]">
            <div class="flex h-full max-h-screen flex-col gap-2">
                <div class="flex h-14 items-center border-b px-4 lg:h-[60px]">
                    <WalletState />
                </div>
                <div class="flex-1 overflow-x-auto scrollbar-hide">
                    {#if $layout?.sidebar}
                        <svelte:component this={$layout.sidebar.component} {...$layout.sidebar.props} />
                    {/if}
                </div>
                <div class="mt-auto">
                    {#if $layout?.footer}
                        <svelte:component this={$layout.footer.component} {...$layout.footer.props} />
                    {/if}
                </div>
            </div>
        </div>
    {/if}

    <!-- Main content -->
    <div class="flex flex-col">
        <!-- Header 1 -->
        <header class="
            mobile-nav
            flex items-center gap-4 border-b px-4 h-[60px] lg:px-6 fixed top-0 w-full
            z-50
        ">
            <div class="w-full">
                {#if $layout.header || $layout.title}
                    <LayoutHeader />
                {:else if $appMobileView}
                    <WalletState />
                {:else}
                    <LayoutHeaderNavigation />
                {/if}
            </div>
        </header>
        <div class="h-[60px]"></div>

        <!-- Optional Navigation Bar (when there is a header) -->
        {#if $layout.navigation !== false && ($layout.header || $layout.title || $appMobileView)}
            <header class="
                mobile-nav
                flex items-center gap-4 border-b h-[60px] lg:px-6 fixed top-[60px] w-full
                z-50
            ">
                <div class="w-full">
                    <LayoutHeaderNavigation />
                </div>
            </header>
            <div class="h-[60px]"></div>
        {/if}

        <main class="
            flex flex-1 flex-col gap-4 lg:gap-6 lg:p-6
            overflow-x-clip
            {(withSidebar && !$appMobileView) ? "" : "lg:max-w-[var(--content-focused-width)] mx-auto lg:w-full lg:px-0 max-sm:w-screen"}
        ">
            <slot />
        </main>
        {#if $appMobileView}
            {#if $layout.footer}
                <footer class="mobile-nav fixed bottom-0 w-full">
                    <svelte:component this={$layout.footer.component} {...$layout.footer.props} />
                </footer>
            {/if}
        {/if}
    </div>
</div>

<Modal />

<Toaster />