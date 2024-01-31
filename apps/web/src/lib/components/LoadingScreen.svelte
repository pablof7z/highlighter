<script lang="ts">
	import { fade } from 'svelte/transition';
	import { onDestroy, onMount } from 'svelte';
	import LoadLogo from '$icons/LoadLogo.svelte';

    export let ready = false;

    let logoPosition = 0;
    let shadowWidth = 150;
    let shadowHeight = 30;

    function updateAnimations() {
        const logoY = Math.sin(Date.now() * 0.004) * 120;
        logoPosition = logoY;
        shadowWidth = 100 + logoY/6;
        shadowHeight= 10 + logoY/21;
    }

    let animationInterval: NodeJS.Timeout;

    onMount(() => {
        animationInterval = setInterval(updateAnimations, 16);
    });

    onDestroy(() => {
        clearInterval(animationInterval);
    });
</script>



{#if ready}
    <div class={$$props.class??""} transition:fade>
        <slot />
    </div>
{:else}
    <div class="w-screen h-screen top-0 left-0 fixed flex flex-col gap-10 justify-center items-center loading-screen" transition:fade>
        {#if $$slots.loading}
            <slot name="loading" />
        {/if}
        <div class="loading-container">
            <div class="w-[150px] sm:h-[20vh] sm:max-h-[300px] mb-6">
                <LoadLogo class="w-full h-full" />
            </div>
            <div class="shadow" style="width: {shadowWidth}px; height: {shadowHeight}px;" />
        </div>
    </div>
{/if}

<style>
    .loading-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100vh;
        background-color: #000;
    }

    .shadow {
        border-radius: 50%;
        background-color: #232323;
    }
</style>