<script lang="ts">
    import * as DropdownMenu from "$components/ui/dropdown-menu";
	import { Copy } from "phosphor-svelte";
    
    export let payload: string | object;
    export let open: boolean;

    if (typeof payload === "object") {
        payload = JSON.stringify(payload, null, 2);
    }

    let copied = false;

    function clicked(e: Event) {
        navigator.clipboard.writeText(payload as string);
        copied = true;
        setTimeout(() => {
            copied = false;
            open = false;
        }, 1000);

        e.preventDefault();
    }
</script>

<DropdownMenu.Item on:click={clicked}>
    <Copy class="mr-2" />
    {#if copied}
        Copied!
    {:else}
        <slot />
    {/if}
</DropdownMenu.Item>