<script lang="ts">
	import { pushState } from "$app/navigation";
	import { page } from "$app/stores";
	import { detailView, layoutMode } from "$stores/layout";
	import { List, X } from "phosphor-svelte";
    import { Drawer } from "vaul-svelte";

    let hasRightSidebarExpanded = false;

    $: hasRightSidebarExpanded = !!$detailView;

    function closeDetailView() {
        pushState($page.url.href, '');
        hasRightSidebarExpanded = false;
        $detailView = null;
        // pushState('', '');
        // page.update((p) => {
        //     p.state.detailView = undefined;
        // });
    }

    let showX = true;
    let listMode = false;
    let listModeDrawerActive = false;

    $: listMode = $layoutMode !== "list-column";
    $: showX = $layoutMode !== "list-column";
    
</script>

<!-- <div class="backdrop backdrop-blur-sm backdrop-filter backdrop-blur-sm bg-base-900 bg-opacity-50 fixed inset-0 z-[998] hidden={!hasRightSidebarExpanded}" on:click={closeDetailView}></div> -->

<aside class="
    sticky sm:top-[var(--layout-header-height)]
    max-h-screen overflow-y-auto overflow-x-clip
    !border-x !border-base-300

    max-md:fixed max-md:left-0 max-md:top-0 max-md:bottom-0 max-md:overflow-x-auto
    max-md:z-[999999]

    { listMode && listModeDrawerActive ? "max-md:w-[90dvw]" : ""}
    

    {$$props.class??""}
">
    {#if $detailView}
        <button class="sticky top-0 right-4 top-22 z-[999]" class:hidden={!showX} on:click={closeDetailView}>
            <X class="w-6 h-6" />
        </button>

        {#if !showX}
            <List class="w-6 h-6" />
        {/if}
        
        {#key $detailView}
            <svelte:component this={$detailView.component} {...$detailView.props} />
        {/key}
        {:else}
            <slot name="right" />
        {/if}
</aside>
