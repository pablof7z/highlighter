<script lang="ts">
	import { layout } from "$stores/layout";
	import { X, CaretLeft } from "phosphor-svelte";
	import { Button } from "$components/ui/button";

    function leftClicked() {
        if ($layout.back?.url) {
            return;
        }
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
    class="text-primary whitespace-nowrap flex flex-nowrap items-center truncate flex-none"
>
    {#if $layout.back?.icon}
        <span class="inline">
            <svelte:component this={$layout.back.icon} size={24} />
        </span>
    {:else if $layout.back?.label === "Close"}
        <X class="w-5 h-5 inline" />
    {:else if $layout.back?.url}
        <Button variant="secondary" class="rounded-full flex-none w-11 h-11 p-0">
            <CaretLeft size={24} />
        </Button>
    {/if}
</a>