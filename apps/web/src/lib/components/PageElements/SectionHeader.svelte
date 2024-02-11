<script lang="ts">
    import SearchBar from "$components/Page/SearchBar.svelte";
	import Toolbar from "$components/PostEditor/Toolbar.svelte";
    import { mainWrapperMargin, pageHeader, pageSidebar } from "$stores/layout";
	import HeaderLeftButton from "./HeaderLeftButton.svelte";
	import HeaderRightButton from "./HeaderRightButton.svelte";

    let hasSidebar = false;
    $: hasSidebar = !!$pageSidebar?.component;

    let componentEventDirectives = {};
	$: if ($pageHeader?.on) {
        for (const [event, handler] of Object.entries($pageHeader.on)) {
			console.log(event, handler);
            componentEventDirectives[`on:${event}`] = () => handler();
        }
    }

	let value = 1;
</script>

<div class="
    fixed
    {hasSidebar ? "left-116" : "left-20"}
    top-0 right-0
    z-40 h-16
    bg-base-100
    border-b border-base-300 mobile-nav
    bg-opacity-80
    items-center
    flex-row flex {$$props.class??""}
">
    {#if $pageHeader?.title && $pageHeader?.searchBar}
        <div class="absolute left-0 ml-4">
            <h1>{$pageHeader.title}</h1>
        </div>

        <div class="flex flex-grow {$mainWrapperMargin??""}">
            <SearchBar inputClass="focus:!outline-none focus:!border-none" />
        </div>
    {:else if $pageHeader?.left && $pageHeader?.right && $pageHeader?.title}
        <div class="{$mainWrapperMargin??""} grow flex flex-row items-center justify-between {hasSidebar ? "!mx-0" : ""}">
            <div class="px-4 w-1/6 overflow-hidden">
                <HeaderLeftButton />
            </div>

            <h1 class="
                flex flex-row items-center gap-2
                text-center w-2/3 !text-lg
            ">
                <span class="grow truncate">{$pageHeader?.title}</span>
            </h1>

            <div class="px-4 w-1/6 overflow-hidden flex justify-end">
                <HeaderRightButton />
            </div>
        </div>
    {:else if hasSidebar && $pageHeader?.left}
        <div class="px-4 w-96">
            <HeaderLeftButton />
        </div>
    {:else}
        <div class="
            flex flex-row
            w-full
            items-stretch
            {hasSidebar ? "" : $mainWrapperMargin??""}
        ">
            {#if $pageHeader?.component}
                <div class="sm:p-4 w-full">
                    {#if $pageHeader?.component === "post-editor"}
                        <Toolbar />
                    {:else}
                        <svelte:component this={$pageHeader.component} {...$pageHeader.props} />
                    {/if}
                </div>
            {:else if $pageHeader?.searchBar}
                {#if $pageHeader?.title}
                    <h1 class="
                        text-white font-semibold
                        flex flex-row items-center gap-2
                        text-center w-full
                        max-sm:text-lg
                        sm:text-2xl
                        whitespace-nowrap
                        lg:absolute sm:left-24
                    ">
                        {$pageHeader?.title}
                    </h1>
                {/if}
                <div class="
                    max-w-3xl w-full
                    {!hasSidebar ? "mx-auto" : ""}
                ">
                    <SearchBar inputClass="focus:!outline-none focus:!border-none" />
                </div>
            {:else}
                <div class="flex items-center justify-between px-4 w-full">
                    {#if !hasSidebar && $pageHeader?.left}
                        <HeaderLeftButton />
                    {/if}

                    <!-- If we have a sidebar, don't show the title on desktop -->
                    {#if $pageHeader?.title}
                        <h1 class="
                            !items-left
                            flex flex-row
                            gap-2
                            w-full
                            col-span-5
                            text-center
                        ">
                            <span class="truncate">{$pageHeader?.title}</span>
                        </h1>
                    {/if}

                    {#if $pageHeader?.right}
                        <HeaderRightButton />
                    {/if}
                </div>
            {/if}
        </div>
    {/if}
</div>

<div class="h-16" />

<style lang="postcss">
    h1 {
        @apply text-white font-semibold max-sm:text-lg sm:text-2xl whitespace-nowrap;
    }
</style>