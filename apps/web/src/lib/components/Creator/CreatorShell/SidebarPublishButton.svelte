<script lang="ts">
	import NewItemModal from '$modals/NewItemModal.svelte';
	import { PaperPlane } from 'phosphor-svelte';
	import { openModal } from "svelte-modals";

    function open() {
        openModal(NewItemModal)
    }
</script>

<button class="
    xl:py-3 xl:button border-accent2 w-full transition-all duration-300 group
    border-2 xl:hover:bg-accent2/20 xl:bg-transparent
    rounded-full p-2
    !text-white
" on:click={open}>
    <span class="hidden xl:inline">New Post</span>
    <PaperPlane class="
        w-6 h-6
        rotate-45
        xl:group-hover:translate-x-2
        group-hover:rotate-90 transition-all duration-1000

    " />
</button>