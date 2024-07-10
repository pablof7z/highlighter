<script lang="ts">
	import Button from "$components/ui/button/button.svelte";
	import { layout } from "$stores/layout";
	import { CaretLeft } from "phosphor-svelte";

    export let href: string | undefined = undefined;
    export let fn: (() => void) | undefined = undefined;

    $: href ??= $layout.back?.url;

    function click() {
        if (href) return;
        if (fn) fn();
        else window.history.back();
    }
</script>

<Button {href} variant="secondary" on:click={click} class="rounded-full flex-none w-11 h-11 p-0">
    <CaretLeft size={24} />
</Button>