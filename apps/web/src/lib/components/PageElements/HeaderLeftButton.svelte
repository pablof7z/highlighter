<script lang="ts">
	import { pageHeader } from "$stores/layout";
	import { X, CaretLeft } from "phosphor-svelte";

    function leftClicked() {
        if ($pageHeader?.left?.fn) {
            $pageHeader.left.fn();
        }
    }
</script>

{#if $pageHeader?.left}
    <a
        href={$pageHeader.left.url??"#"}
        on:click={leftClicked}
        class="text-accent2 whitespace-nowrap flex flex-nowrap items-center max-w-[15vw]"
    >
        {#if $pageHeader.left.icon}
            <span class="inline">
                <svelte:component this={$pageHeader.left.icon} size={24} />
            </span>
        {:else if $pageHeader.left.label === "Close"}
            <X class="w-5 h-5 inline" />
        {:else if $pageHeader.left.label === "Back"}
            <CaretLeft class="w-5 h-5 inline" />
        {/if}

        <span class="truncate">{$pageHeader.left.label}</span>
    </a>
{/if}