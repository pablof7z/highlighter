<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import NewPost from '$components/Creator/NewPost.svelte';
	import { closeModal } from "$utils/modal";
</script>

<ModalShell color="glassy" class="sm:w-80 lg:max-w-3xl md:w-full overflow-hidden gap-0">
    <NewPost boxClass="pb-0 !bg-transparent" />

	<div class="flex flex-row justify-end w-full px-6 max-sm:hidden">
		<button class="button" on:click={closeModal}>
			Close
		</button>
	</div>
</ModalShell>
