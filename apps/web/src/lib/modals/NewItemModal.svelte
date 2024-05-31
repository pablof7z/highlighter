<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import NewPost from '$components/Creator/NewPost.svelte';
	import { closeModal } from "$utils/modal";
</script>

<ModalShell title="New Publication" class="sm:w-80 lg:max-w-3xl md:w-full overflow-hidden gap-0">
    <NewPost boxClass="px-0 pb-0 !bg-transparent" />

	<svelte:fragment slot="footer">
		<button class="button" on:click={closeModal}>
			Close
		</button>
	</svelte:fragment>
</ModalShell>
