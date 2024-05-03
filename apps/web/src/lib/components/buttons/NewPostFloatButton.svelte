<script lang="ts">
	import NewPostModal from "$modals/NewPostModal.svelte";
	import { modal } from "$stores/layout";
	import { Feather } from "phosphor-svelte";
	import { openModal } from "svelte-modals";

    function open() {
        $modal = {
            component: NewPostModal,
            props: {}
        }
    }
</script>

<button class="
    btn btn-lg p-3 btn-circle bg-accent2 text-white fixed z-[1] bottom-20 right-4
" on:click={open}>
    <Feather class="w-full h-full" weight="fill" />
</button>