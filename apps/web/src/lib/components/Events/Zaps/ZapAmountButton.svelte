<script lang="ts">
	import Button from "$components/ui/button/button.svelte";

    export let title: string;
    export let active = false;
    export let value: number | boolean;
    export let group: number | boolean;
    
    $: active = group === value;

    function click() {
        group = value;
    }
</script>

<div class="flex flex-col items-center gap-1">
    <Button variant={active ? "default" : "secondary"} on:click={click} class="grid place-items-center {$$props.class || ``} ">
        <slot />
    </Button>
    <span
        class="text-xs font-normal"
        class:text-muted-foreground={!active}
        class:text-foreground={active}
    >
        {title}
    </span>
</div>