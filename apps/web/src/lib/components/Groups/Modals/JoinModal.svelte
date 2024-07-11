<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import JoinInfo from "../JoinInfo.svelte";
</script>

<ModalShell
    title="Join"
    containerClass="relative bg-background overflow-clip"
>
    <JoinInfo {...$$props} />
</ModalShell>