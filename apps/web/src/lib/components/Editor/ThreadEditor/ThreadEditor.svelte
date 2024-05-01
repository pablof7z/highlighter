<script lang="ts">
	import { drafts, type DraftItem, DraftCheckpoint } from "$stores/drafts";
	import { newToasterMessage } from "@kind0/ui-common";
	import Shell from "$components/PostEditor/Shell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import currentUser from "$stores/currentUser";
	import ThreadItem from "./ThreadItem.svelte";
	import { Plus } from "phosphor-svelte";
	import { afterUpdate, onDestroy, onMount } from 'svelte';
	import { Thread, saveDraft } from '$utils/thread.js';
	import { currentDraftItem, event } from "$stores/post-editor";
	import { debounce, throttle } from "@sveu/shared";

    export let thread: Thread;
    export let draftItem: DraftItem | undefined = undefined;

    onMount(() => {
        $event = thread;
        console.log('setting event', thread, !!draftItem)
        $currentDraftItem = draftItem;
    })

	afterUpdate(() => {
		$event = thread;
	});

    // if (manuallySaved) goto("/drafts");

	const throttleSave = debounce(() => {
		console.log('saving draft')
		console.log(thread.items[0].event.content)
		const res = saveDraft(false, draftItem, drafts, thread)
		if (res) {
			$drafts = $drafts;
			newToasterMessage("Draft saved", "success");
		}
	}, 2);

	function contentChanged() {
		throttleSave();
	}

	function removeItem(i: number) {
		thread.items.splice(i, 1);
		thread.items = thread.items;
		throttleSave();
	}
</script>

<div class="max-w-3xl w-full sm:px-6">
<Shell type="thread">
	<UserProfile user={$currentUser} let:userProfile>
		{#each thread.items as item, i (item.event.id??Math.random())}
			<ThreadItem
				bind:item
				bind:content={item.event.content}
				{userProfile}
				shouldDisplayVerticalBar={true}
				autofocus={i === thread.items.length - 1}
				on:remove={() => removeItem(i)}
				on:submit={() => {thread.newItem(); thread.items = thread.items}}
				on:contentChanged={contentChanged}
			/>
		{/each}
		<div class="flex flex-col items-center flex-none w-10 sm:w-16 self-stretch">
			<button class="
				btn btn-circle bg-zinc-800 text-white
				transition-all duration-300
				hover:!bg-accent2
				hover:ring-8 ring-accent2/30
			" on:click={() => { thread.newItem(); thread.items = thread.items }}>
				<Plus size={24} weight="bold" />
			</button>
		</div>
	</UserProfile>
</Shell>
</div>