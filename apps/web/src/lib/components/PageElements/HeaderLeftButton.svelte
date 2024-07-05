<script lang="ts">
	import { pageHeader } from "$stores/layout";
	import { X, CaretLeft } from "phosphor-svelte";
	import BackButton from "./Navigation/BackButton.svelte";

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
        class="text-primary whitespace-nowrap flex flex-nowrap items-center w-2/12 truncate"
    >
        {#if $pageHeader.left.icon}
            <span class="inline">
                <svelte:component this={$pageHeader.left.icon} size={24} />
            </span>
        {:else if $pageHeader.left.label === "Close"}
            <X class="w-5 h-5 inline" />
        {:else if $pageHeader.left.label === "Back"}
            <BackButton />
        {/if}
    </a>
{/if}