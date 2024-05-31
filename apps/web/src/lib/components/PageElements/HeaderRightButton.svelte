<script lang="ts">
	import { pageHeader } from "$stores/layout";
	import { X, CaretLeft } from "phosphor-svelte";

    function clicked() {
        if ($pageHeader?.right?.fn) {
            $pageHeader.right.fn();
        }
    }
</script>

{#if $pageHeader?.right}
    <a
        href={$pageHeader.right.url??"#"}
        on:click={clicked}
        class="text-accent2 whitespace-nowrap flex flex-nowrap items-center max-w-[15vw]"
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
    </a>
{/if}