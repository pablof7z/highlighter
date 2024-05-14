<script lang="ts">
	import { page } from '$app/stores';
	import { modalState } from '$stores/layout';
	import { onDestroy, onMount } from 'svelte';
	import { onBeforeClose } from "svelte-modals";
    import { closeModal } from '$utils/modal';
    import Device from "svelte-device-info";

    export let color: "white" | "black" | "glassy" = "glassy";

    const isPhone = Device.isPhone;

    const slideAnimationDuration = 300;

    let url = $page.url.pathname;
    $: if ($page.url.pathname !== url) closeModal();

    let mounted = false;
    let containerEl: HTMLElement;

    onMount(() => {
        mounted = true;
        $modalState = "open";
    });

    if (!isPhone) {
        onBeforeClose(() => {
            if (mounted === true) {
                $modalState = "closing";
                mounted = false;
                setTimeout(closeModal, slideAnimationDuration);
                return false;
            }
        });
    }

    onDestroy(() => {
        $modalState = "closed";
        window.visualViewport?.removeEventListener("resize", resizeHandler);
    })

    const viewport = window.visualViewport;

    onMount(() => {
        if (viewport) window.visualViewport?.addEventListener("resize", resizeHandler);

        // add an event listener that fires on any input element focus
        document.body.addEventListener("focus", resizeHandler);
        document.body.addEventListener("blur", resizeHandler);
    })

    let height = viewport?.height;

    function resizeHandler() {
        if (!containerEl) return;
        
        if (!/iPhone|iPad|iPod/.test(window.navigator.userAgent)&& viewport?.height && height && viewport.height !== height) {
            containerEl.style.bottom = `${height - viewport.height + 10}px`;
        }
    }
</script>

{#if isPhone}
    <div class="{$$props.class??""}">
        <slot />
    </div>
{:else}
    <div class="fixed top-0 bottom-0 left-0 w-screen h-screen z-[98] flex items-center justify-center pointer-events-none {color}" bind:this={containerEl}>
        <div class="
            max-sm:fixed max-sm:top-0 max-sm:bottom-0 z-[99] max-sm:w-full  max-sm:!pb-0
            {$$props.class??""}
        ">
            {#if mounted}
                <div class="
                    card
                    !rounded-3xl
                    max-sm:!rounded-b-none
                    shadow-xl
                    flex flex-col
                    overflow-y-auto
                    w-fit mx-auto
                    p-6
                    h-full
                    {$$props.class}
                " style="pointer-events: auto; max-height: 92vh;"
                >
                    <div class="!rounded-3xl inner flex flex-col items-center transition-all duration-1000 gap-6
                    {$$props.class}">
                        <slot />
                    </div>
                </div>
            {/if}
        </div>
    </div>
{/if}



<style lang="postcss">
    .white .card .inner {
        @apply bg-white;
    }

    .black .card .inner {
        @apply bg-black border border-base-300 p-10;
    }

    .glassy .card {
        @apply bg-base-200 bg-opacity-80 backdrop-blur-[48px];
        @apply border border-white/10;
    }
</style>