<script lang="ts">
	import Button from "$components/ui/button/button.svelte";
	import { CaretLeft } from "phosphor-svelte";

    export let href: string | undefined = undefined;
    export let fn: (() => void) | undefined = undefined;

    function click() {
        if (href) return;
        if (fn) fn();
        else window.history.back();
    }
</script>

<Button {href} variant="secondary" on:click={click} class="rounded-full flex-none w-8 h-8 p-0">
    <CaretLeft size={24} />
</Button>