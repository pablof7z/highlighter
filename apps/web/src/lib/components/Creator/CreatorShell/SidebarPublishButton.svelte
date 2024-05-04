<script lang="ts">
	import NewItemModal from '$modals/NewItemModal.svelte';
	import { PaperPlane } from 'phosphor-svelte';
	import { openModal } from '$utils/modal';

    function open() {
        openModal(NewItemModal)
    }
</script>

<button class="
    lg:py-3 lg:button border-accent2 w-full transition-all duration-300 group
    border-2 lg:hover:bg-accent2/20 lg:bg-transparent
    rounded-full p-2
    !text-white
" on:click={open}>
    <span class="hidden lg:inline">New Post</span>
    <PaperPlane class="
        w-6 h-6
        rotate-45
        lg:group-hover:translate-x-2
        group-hover:rotate-90 transition-all duration-1000

    " />
</button>