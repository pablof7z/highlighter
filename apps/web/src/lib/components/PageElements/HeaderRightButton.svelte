<script lang="ts">
    import { pageHeader } from "$stores/layout";
	import { PaperPlaneTilt, CaretRight } from "phosphor-svelte";

    function rightClicked() {
        if ($pageHeader?.rightFn) {
            $pageHeader.rightFn();
        }
    }
</script>

{#if $pageHeader?.rightLabel}
    <a
        href={$pageHeader?.rightUrl??"#"}
        on:click={rightClicked}
        class="text-accent2 whitespace-nowrap"
    >
        {#if $pageHeader.rightLabel === "loading"}
            <span class="loading loading-sm" />
        {:else}
            {$pageHeader.rightLabel}

            {#if $pageHeader.rightIcon}
                <span class="w-5 h-5 inline">
                    <svelte:component this={$pageHeader.rightIcon} class="inline" />
                </span>
            {:else if $pageHeader.rightLabel === "Next"}
                <CaretRight class="w-5 h-5 inline" />
            {:else if $pageHeader.rightLabel === "Publish"}
                <PaperPlaneTilt class="w-5 h-5 inline" />
            {/if}
        {/if}
    </a>
{/if}