<script lang="ts">
	import { fade } from 'svelte/transition';
	import { onDestroy, onMount } from 'svelte';

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
            <svg xmlns="http://www.w3.org/2000/svg" width="209" height="209" viewBox="0 0 209 209" fill="none" class="w-36 h-36 mb-4">
                    <g clip-path="url(#clip0_1611_3249)">
                      <path d="M0 56.8001C0 25.6001 25.5 0.100098 56.7 0.100098H151.9C183.1 0.100098 208.6 25.6001 208.6 56.8001V152C208.6 183.2 183.1 208.7 151.9 208.7H56.7C25.5 208.7 0 183.2 0 152V56.8001Z" fill="black"/>
                      <g opacity="0.16">
                        <path d="M0 56.7C0 25.5 25.5 0 56.7 0H151.9C183.1 0 208.6 25.5 208.6 56.7V152.1C208.6 183.3 183.1 208.8 151.9 208.8H56.7C25.5 208.8 0 183.3 0 152.1V56.7Z" fill="url(#paint0_linear_1611_3249)"/>
                      </g>
                      <path d="M118.199 59.8002C120.099 59.8002 121.799 60.5002 123.099 61.8002L159.399 98.0002C162.099 100.7 162.099 105.2 159.399 107.9L123.199 144.1C121.899 145.4 120.099 146.1 118.299 146.1C116.399 146.1 114.699 145.4 113.399 144.1L77.1988 107.9C74.4988 105.2 74.4988 100.7 77.1988 98.0002L113.399 61.8002C114.599 60.5002 116.399 59.8002 118.199 59.8002ZM118.199 51.7002C114.399 51.7002 110.499 53.2002 107.599 56.1002L71.3988 92.4002C65.5988 98.2002 65.5988 107.8 71.3988 113.6L107.599 149.8C110.499 152.7 114.399 154.2 118.199 154.2C121.999 154.2 125.899 152.7 128.799 149.8L164.999 113.6C170.799 107.8 170.799 98.2002 164.999 92.4002L128.799 56.2002C125.999 53.2002 122.099 51.7002 118.199 51.7002Z" fill="url(#paint1_radial_1611_3249)"/>
                      <path d="M46.8997 157.1C38.6997 157.1 36.6997 152.3 42.4997 146.5L55.7997 133.2C61.5997 127.4 71.1997 127.4 76.9997 133.2L90.2997 146.5C96.0997 152.3 94.0997 157.1 85.8997 157.1H46.8997Z" fill="url(#paint2_radial_1611_3249)"/>
                      <g opacity="0.08">
                        <path d="M0 56.8001C0 25.6001 25.5 0.100098 56.7 0.100098H151.9C183.1 0.100098 208.6 25.6001 208.6 56.8001V152C208.6 183.2 183.1 208.7 151.9 208.7H56.7C25.5 208.7 0 183.2 0 152V56.8001Z" fill="url(#paint3_radial_1611_3249)"/>
                      </g>
                    </g>
                    <defs>
                      <linearGradient id="paint0_linear_1611_3249" x1="-4.436e-05" y1="104.411" x2="208.577" y2="104.411" gradientUnits="userSpaceOnUse">
                        <stop stop-color="#589FFF"/>
                        <stop offset="1" stop-color="#9068FF"/>
                      </linearGradient>
                      <radialGradient id="paint1_radial_1611_3249" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(170.848 45.697) scale(155.041 155.041)">
                        <stop stop-color="#589FFF"/>
                        <stop offset="1" stop-color="#9068FF"/>
                      </radialGradient>
                      <radialGradient id="paint2_radial_1611_3249" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(111.171 24.4607) scale(172.527 172.527)">
                        <stop stop-color="#FF00FF"/>
                        <stop offset="1" stop-color="#FF931E"/>
                      </radialGradient>
                      <radialGradient id="paint3_radial_1611_3249" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(98.2461 52.869) scale(245.174 245.174)">
                        <stop stop-color="#589FFF"/>
                        <stop offset="0.0089402" stop-color="white"/>
                        <stop offset="1" stop-color="#9068FF" stop-opacity="0"/>
                      </radialGradient>
                      <clipPath id="clip0_1611_3249">
                        <rect width="208.6" height="208.8" fill="white"/>
                      </clipPath>
                    </defs>
                  </svg>
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