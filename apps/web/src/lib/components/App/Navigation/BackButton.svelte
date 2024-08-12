<script lang="ts">
	import { goto } from "$app/navigation";
	import Button from "$components/ui/button/button.svelte";
	import { layout } from "$stores/layout";
	import { CaretLeft } from "phosphor-svelte";

    export let href: string | undefined = undefined;
    export let fn: (() => void) | undefined = undefined;

    $: href ??= $layout.back?.url;

    function click(e: MouseEvent) {
        console.log("click", href);
        if (href) return;
        if (fn) fn();
        else if (window.history.length > 1) window.history.back();
        else goto("/");
    }
</script>

<Button {href} variant="secondary" on:click={click} class="rounded-full flex-none w-11 h-11 p-0">
    <CaretLeft size={24} />
</Button>