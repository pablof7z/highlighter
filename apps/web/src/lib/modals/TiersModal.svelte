<script lang="ts">
	import TierList from "$components/Creator/TierList.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from "svelte-modals";
</script>

<ModalShell
    color="black"
    class="w-full max-w-2xl flex flex-col items-stretch overflow-y-auto max-h-[70vh]"
>
    <TierList
        redirectOnSave={false}
        on:saved={closeModal}
    />

    <!-- close button -->
    <button
        class="button button-black py-3 w-fit px-10 self-center"
        on:click|stopPropagation|preventDefault={closeModal}
    >
        Close
    </button>
</ModalShell>