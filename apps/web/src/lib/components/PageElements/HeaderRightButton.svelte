<script lang="ts">
    import { pageHeader } from "$stores/layout";
	import { PaperPlaneTilt, CaretRight } from "phosphor-svelte";

    function rightClicked() {
        if ($pageHeader?.right?.fn) {
            $pageHeader.right.fn();
        }
    }
</script>

{#if $pageHeader?.right}
    <a
        href={$pageHeader?.right.url??"#"}
        on:click={rightClicked}
        class="text-accent2 whitespace-nowrap text-right self-end"
    >
        {#if $pageHeader.right.label === "loading"}
            <span class="loading loading-sm" />
        {:else}
            {#if !$pageHeader.title || $pageHeader.title.length < 10}
                {$pageHeader.right.label}
            {/if}

            {#if $pageHeader.right.icon}
                <span class="w-5 h-5 inline">
                    <svelte:component this={$pageHeader.right.icon} class="inline" />
                </span>
            {:else if $pageHeader.right.label === "Next"}
                <CaretRight class="w-5 h-5 inline" />
            {:else if $pageHeader.right.label === "Publish"}
                <PaperPlaneTilt class="w-5 h-5 inline" />
            {/if}
        {/if}
    </a>
{/if}