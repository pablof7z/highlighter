<script lang="ts">
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from "$utils/modal";
	import Search from "$views/Search.svelte";

    export let value: string = "";
</script>

<ModalShell color="glassy" class="max-w-2xl w-full lg:max-h-[70vh] !gap-0">
    <Search value={value} on:done={closeModal} />
</ModalShell>
