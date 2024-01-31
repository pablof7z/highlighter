<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import NewPost from '$components/Creator/NewPost.svelte';
</script>

<ModalShell color="glassy" class="w-[80dvw] max-sm:max-w-[17rem] sm:w-80 lg:max-w-3xl md:w-full overflow-hidden">
    <NewPost boxClass="!bg-transparent" />
</ModalShell>
