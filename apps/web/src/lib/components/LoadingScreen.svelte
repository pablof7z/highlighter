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
    <div class="w-screen h-screen top-0 left-0 fixed flex justify-center items-center" transition:fade>
        <div class="w-24 h-24 animate-pulse scale-150">
            $user = {!!$user}
            <Logo />
        </div>
    </div>
{/if}