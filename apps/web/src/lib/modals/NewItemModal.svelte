<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import NewPost from "$components/Creator/NewPost.svelte";
	import { NavigationOption } from "../../app";
	import NewPostModalInner from "./NewPostModalInner.svelte";

	let title = "New Publication";
	let wrapperClass = "lg:max-w-md md:w-full overflow-hidden gap-0";
	let actionButtons: NavigationOption[] = [];

	let showNewShortPost = false;

	function onNewShortPost() {
		title = "New Post";
		showNewShortPost = true;
	}
</script>

<ModalShell {title} class={wrapperClass} {actionButtons}>
	{#if !showNewShortPost}
		<NewPost boxClass="px-0 pb-0 !bg-transparent" {onNewShortPost} />
	{:else}
		<NewPostModalInner bind:title bind:wrapperClass bind:actionButtons />
	{/if}
</ModalShell>
