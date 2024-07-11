<script lang="ts">
	import { layout } from "$stores/layout";
	import { X, CaretLeft } from "phosphor-svelte";
	import BackButton from "./Navigation/BackButton.svelte";

    function leftClicked() {
        if ($layout.back?.fn) {
            $layout.back.fn();
        } else {
            window.history.back();
        }
    }
</script>

<a
    href={$layout.back?.url??"#"}
    on:click={leftClicked}
    class="text-primary whitespace-nowrap flex flex-nowrap items-center truncate"
>
    {#if $layout.back?.icon}
        <span class="inline">
            <svelte:component this={$layout.back.icon} size={24} />
        </span>
    {:else if $layout.back?.label === "Close"}
        <X class="w-5 h-5 inline" />
    {:else if $layout.back?.url}
        <BackButton href={$layout.back.url} />
    {:else if !$layout.back}
        <BackButton />
    {/if}
</a>