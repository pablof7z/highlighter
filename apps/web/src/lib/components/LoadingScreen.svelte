<script lang="ts">
	import { fade } from 'svelte/transition';
	import Logo from "$icons/Logo.svelte";
	import { user } from '@kind0/ui-common';

    export let ready = false;
</script>

{#if ready}
    <div class={$$props.class??""} transition:fade>
        <slot />
    </div>
{:else}
    <div class="w-screen h-screen top-0 left-0 fixed flex flex-col gap-10 justify-center items-center" transition:fade>
        {#if $$slots.loading}
            <slot name="loading" />
        {/if}
        <div class="w-24 h-24 animate-pulse scale-150">
            <Logo />
        </div>
    </div>
{/if}