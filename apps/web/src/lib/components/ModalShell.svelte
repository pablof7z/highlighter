<script lang="ts">
	import { page } from '$app/stores';
	import { closeModal } from "svelte-modals";
	import { fade } from "svelte/transition";

    export let color: "white" | "black" | "glassy" = "white";

    let url = $page.url.pathname;
    $: if ($page.url.pathname !== url) closeModal();
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="
    fixed
    h-screen top-0 bottom-0 left-0 px-4 lg:px-0
    flex flex-col justify-center items-center
    z-40
    w-screen
    pointer-events-none
    {color}
">
    <div class="relative z-50 w-full {$$props.class??""}">
        <div class="
            card
            !rounded-3xl
            shadow-xl
            transition-all duration-1000
            flex flex-col
            overflow-y-hidden
            w-fit mx-auto
            {$$props.class}
        " style="pointer-events: auto; max-height: 92vh;" transition:fade>
            <div class="!rounded-3xl inner shadow-lg p-6 flex flex-col items-center transition-all duration-1000 gap-6 {$$props.class}">
                <slot />
            </div>
        </div>
        <slot name="after" />
    </div>
</div>

<style lang="postcss">
    .white .card .inner {
        @apply bg-white;
    }

    .black .card .inner {
        @apply bg-black border border-base-300 p-10;
    }

    .glassy .card {
        @apply bg-zinc-800 bg-opacity-50 backdrop-blur-[48px];
        @apply border border-white/10;
    }
</style>