<script lang="ts">
	import { pageHeader } from "$stores/layout";
	import { X, CaretLeft } from "phosphor-svelte";

    function leftClicked() {
        if ($pageHeader?.leftFn) {
            $pageHeader.leftFn();
        }
    }
</script>

{#if $pageHeader?.leftLabel}
    <a
        href={$pageHeader?.leftUrl??"#"}
        on:click={leftClicked}
        class="text-accent2 whitespace-nowrap flex flex-nowrap items-center max-w-[15vw]"
    >
        {#if $pageHeader.leftIcon}
            <span class="w-5 h-5 inline">
                <svelte:component this={$pageHeader.leftIcon} />
            </span>
        {:else if $pageHeader.leftLabel === "Close"}
            <X class="w-5 h-5 inline" />
        {:else if $pageHeader.leftLabel === "Back"}
            <CaretLeft class="w-5 h-5 inline" />
        {/if}

        <span class="truncate">{$pageHeader.leftLabel}</span>
    </a>
{/if}