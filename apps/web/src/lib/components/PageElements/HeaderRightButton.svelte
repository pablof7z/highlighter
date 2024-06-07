<script lang="ts">
	import { Button } from "$components/ui/button";
	import { pageHeader } from "$stores/layout";
	import { X, CaretLeft } from "phosphor-svelte";

    function clicked() {
        if ($pageHeader?.right?.fn) {
            $pageHeader.right.fn();
        }
    }
</script>

{#if $pageHeader?.right}
    <div class="w-2/12">
        <Button
            href={$pageHeader.right.url??"#"}
            on:click={clicked}
            variant="accent"
            class="whitespace-nowrap flex flex-nowrap items-center"
        >
            {#if $pageHeader.right.icon}
                <span class="inline">
                    <svelte:component this={$pageHeader.right.icon} size={24} />
                </span>
            {:else if $pageHeader.right.label === "Close"}
                <X class="w-5 h-5 inline" />
            {:else if $pageHeader.right.label === "Back"}
                <CaretLeft class="w-5 h-5 inline" />
            {/if}

            {#if $pageHeader.right.label}
                <span class="truncate">{$pageHeader.right.label}</span>
            {/if}
        </Button>
    </div>
{/if}