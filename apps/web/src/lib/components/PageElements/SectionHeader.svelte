<script lang="ts">
	import SearchBar from "$components/Page/SearchBar.svelte";
import { mainWrapperMargin, pageHeader, pageSidebar } from "$stores/layout";

    export let title: string;

    let hasSidebar = false;
    $: hasSidebar = !!$pageSidebar?.component;
</script>

<div class="
    w-full z-50 fixed h-16
    bg-base-100 max-sm:mobile-nav
    p-4
    border-b border-base-300
    flex-row justify-between items-center inline-flex shrink-0 {$$props.class??""}
">
    <div class="
        flex flex-row
        w-full
        items-stretch
    ">
        <div class="flex items-center justify-between relative">
            <!-- If we have a sidebar, don't show the title on desktop -->
            {#if !hasSidebar}
                <h1 class="
                    text-white font-semibold
                    flex flex-row items-center gap-2
                    max-sm:text-lg
                    sm:text-xl
                    whitespace-nowrap
                    {$pageHeader?.searchBar ? "sm:absolute sm:left-0" : ""}
                "

                >
                    {title}
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
    </div>
</div>

<div class="h-16" />