<script lang="ts">
	import { modals } from "$stores/layout";
</script>

{#each $modals as modal}
	<svelte:component this={modal.component} {...modal.props} />
{/each}
