<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import RecommendedMintList from "$components/Wallet/RecommendedMintList.svelte";
	import { closeModal } from "$utils/modal";

    export let onClick: (url: string) => void;
</script>

<ModalShell
    title="Select mint"
    class="max-w-xl w-full"
>
    <RecommendedMintList on:click={(e) => {
        onClick(e.detail.url);
        closeModal();

    }} />
</ModalShell>