<script lang="ts">
	import { closeModal } from "svelte-modals";
	import { fade } from "svelte/transition";

    export let color: "white" | "black" = "white";
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="
    fixed
    h-screen top-0 bottom-0 left-0 px-4 lg:px-0
    flex justify-center items-center
    z-40
    w-screen
    {color}
" transition:fade on:click={closeModal}>
    <div class="
        card
        !rounded-3xl
        shadow-xl
        flex flex-col
        z-50
        relative
        overflow-y-hidden
        {$$props.class}
    " style="pointer-events: auto; max-height: 92vh;" transition:fade>
        <div class="!rounded-3xl inner shadow-lg p-6 flex flex-col items-center gap-6 {$$props.class}">
            <slot />
        </div>
    </div>
</div>

<style lang="postcss">
    .white .card .inner {
        @apply bg-white;
    }

    .black .card .inner {
        @apply bg-black border border-base-300;
    }
</style>