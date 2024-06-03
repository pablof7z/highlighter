<script lang="ts">
	import currentUser from "$stores/currentUser.js";
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