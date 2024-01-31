<script lang="ts">
    import SearchBar from "$components/Page/SearchBar.svelte";
	import Toolbar from "$components/PostEditor/Toolbar.svelte";
    import { mainWrapperMargin, pageHeader, pageSidebar } from "$stores/layout";

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
    sm:pl-20
    fixed
    w-full
    z-40 h-16
    bg-base-100 mobile-nav
    border-b border-base-300
    mobile-nav
    bg-opacity-80
    flex-row justify-between items-center inline-flex shrink-0 {$$props.class??""}
">
    <div class="
        flex flex-row
        w-full
        items-stretch
        {hasSidebar ? "lg:pl-96" : $mainWrapperMargin??""}
    ">
        {#if $pageHeader?.component}
            <div class="sm:p-4 w-full">
                {#if $pageHeader?.component === "post-editor"}
                    <Toolbar />
                {:else}
                    <svelte:component this={$pageHeader.component} {...$pageHeader.props} />
                {/if}
            </div>
        {:else}
            <div class="flex items-center justify-between">
                <!-- {#if $pageHeader?.left}
                    <HeaderLeftButton />
                {/if} -->

                <!-- If we have a sidebar, don't show the title on desktop -->
                {#if $pageHeader?.title}
                    <h1 class="
                        text-white font-semibold
                        flex flex-row items-center gap-2
                        text-center w-full
                        max-sm:text-lg
                        sm:text-2xl
                        whitespace-nowrap
                        {$pageHeader?.searchBar ? "sm:absolute sm:left-24" : "justify-center"}
                    ">
                        {$pageHeader?.title}
                    </h1>
                {/if}
            </div>

            {#if $pageHeader?.searchBar}
                <div class="
                    max-w-3xl w-full
                    {!hasSidebar ? "mx-auto" : ""}
                ">
                    <SearchBar inputClass="focus:!outline-none focus:!border-none" />
                </div>
            {/if}
            <!-- {#if $pageHeader?.right}
                <HeaderRightButton />
            {/if} -->
        {/if}
    </div>
</div>

<div class="h-16" />