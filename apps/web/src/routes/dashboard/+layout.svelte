<script lang="ts">
	import { user } from "@kind0/ui-common";
	import { onMount } from "svelte";

    let mounted = false;

    onMount(() => {
        mounted = true;
    });
</script>

{#if mounted}
    {#if !$user}
        Must be logged in
    {:else}
        <slot />
    {/if}
{/if}