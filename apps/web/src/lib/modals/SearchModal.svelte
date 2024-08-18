<script lang="ts">
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from "$utils/modal";
	import Search from "$views/Search.svelte";

    export let value: string = "";
</script>

<ModalShell
    class="
        max-w-2xl !top-[20dvh] w-full lg:max-h-[70vh] !gap-0 lg:h-[50vh] overflow-clip !p-0
        !translate-y-0
    "
>
    <Search value={value} on:done={closeModal} inputContainerClass="px-6 py-4" />
</ModalShell>
