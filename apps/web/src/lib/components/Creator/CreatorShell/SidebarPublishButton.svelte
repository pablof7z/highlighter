<script lang="ts">
	import NewItemModal from '$modals/NewItemModal.svelte';
	import { PaperPlane } from 'phosphor-svelte';
	import { openModal } from "svelte-modals";

    function open() {
        openModal(NewItemModal)
    }
</script>

<button class="py-3 button w-full group" on:click={open}>
    New Post
    <PaperPlane class="
        w-6 h-6
        rotate-45
        group-hover:rotate-90 group-hover:scale-125 transition-transform duration-500

    " />
</button>