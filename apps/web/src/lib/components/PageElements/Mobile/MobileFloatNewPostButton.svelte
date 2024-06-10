<script lang="ts">
	import { Fab } from "konsta/svelte";
	import { Plus } from "phosphor-svelte";
    import NewItemModal from "$modals/NewItemModal.svelte";
	import { openModal } from "$utils/modal";
</script>

<Fab
    class="fixed right-4-safe ios:bottom-15-safe material:bottom-18-safe z-20 !bg-accent"
    onClick={() => openModal(NewItemModal)}
>
    <Plus size={24} />
</Fab>