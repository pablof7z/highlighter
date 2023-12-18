<script lang="ts">
	import { closeModal } from "svelte-modals";
	import { fade } from "svelte/transition";
</script>

<div class="
    fixed
    h-screen top-0 bottom-0 left-0 px-4 lg:px-0
    flex justify-center items-center
    z-50
    w-screen
" transition:fade on:click={closeModal}>
    <div class="
        card
        !rounded-3xl
        shadow-xl
        flex flex-col
        relative
        overflow-y-hidden
        {$$props.class}
    " style="pointer-events: auto; max-height: 92vh;" on:click|stopPropagation={()=>{}} transition:fade>
        <div class="bg-white shadow-lg p-6 flex flex-col items-center gap-6 {$$props.class}">
            <slot />
        </div>
    </div>
</div>
