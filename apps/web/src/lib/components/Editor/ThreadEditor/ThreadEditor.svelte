<script lang="ts">
	import { drafts, type DraftItem, DraftCheckpoint } from "$stores/drafts";
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import Shell from "$components/PostEditor/Shell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import currentUser from "$stores/currentUser";
	import ThreadItem from "./ThreadItem.svelte";
	import { Plus } from "phosphor-svelte";
	import { afterUpdate, onMount } from 'svelte';
	import { Thread, saveDraft } from '$utils/thread.js';
	import { currentDraftItem, event, view } from "$stores/post-editor";
	import { debounce } from "@sveu/shared";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";

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

	let currentView = "view-edit";
	let previewEvents: NDKEvent[] = [];
	
	$: if (currentView !== $view) {
        if ($view === "view-preview") {
			previewEvents = [];
			for (const item of thread.items) {
				const e = new NDKEvent($ndk, item.event.rawEvent());
				e.content = [e.content, ...item.urls].join("\n\n");
				e.pubkey = $currentUser!.pubkey;
				e.author = $currentUser!;
				e.id = Math.random().toString(36).substring(7);
				previewEvents.push(e);
			}
			
			previewEvents = previewEvents;
			currentView = $view;
        } else {
            currentView = $view;
        }
    }
</script>

<div class="max-w-3xl w-full sm:px-6 overflow-x-clip">
<Shell
	type="thread"
	on:prepare
>
	<UserProfile user={$currentUser} let:userProfile>
		{#each thread.items as item, i (i)}
			<ThreadItem
				bind:item
				bind:content={item.event.content}
				bind:urls={item.urls}
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
	<div slot="viewPreview" class="discussion-wrapper">
		{#key $view}
			{#each previewEvents as event, i (i)}
				<div class="discussion-item">
					<AvatarWithName user={$currentUser} avatarSize="medium" spacing="gap-4" nameClass="text-sm opacity-50" />
					<div class="pl-14 py-6">
						<EventContent ndk={$ndk} event={event} />
					</div>
				</div>
			{/each}
		{/key}
	</div>
</Shell>
</div>