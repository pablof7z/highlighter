<script lang="ts">
	import { pageSidebar } from "$stores/layout.js";

    let hasFocus: boolean;

    $: hasFocus = !!$pageSidebar?.focused;
</script>

{#if $pageSidebar}
    <div class="
        {$$props.class??""}
        flex-none

        {hasFocus ?
            "max-lg:fixed max-lg:left-0 max-lg:bottom-0 max-lg:overflow-x-auto max-lg:bg-base-100" :
            "max-lg:hidden"
        }

        lg:w-[500px]
        max-sm:w-full
        h-screen sticky top-0
    ">
        
        <svelte:component this={$pageSidebar.component} {...$pageSidebar.props} />
    </div>
{/if}