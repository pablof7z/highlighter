<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import LnQrCode from "$components/Payment/LnQrCode.svelte";

    export let pr: string;
    export let satAmount: number;
    export let title: string;
</script>

<ModalShell {title}>
    <LnQrCode {pr} {satAmount} />
</ModalShell>