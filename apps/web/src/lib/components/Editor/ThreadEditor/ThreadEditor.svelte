<script lang="ts">
	import { drafts, type DraftItem, DraftCheckpoint } from "$stores/drafts";
	import Shell from "$components/PostEditor/Shell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import currentUser from "$stores/currentUser";
	import { Plus } from "phosphor-svelte";
	import { afterUpdate, onMount } from 'svelte';
	import { Thread } from '$utils/thread.js';
	import { event, view } from "$stores/post-editor";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { addDraftCheckpoint } from "$utils/drafts";
	import { pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { newToasterMessage } from "$stores/toaster";

    export let thread: Thread;
    export let draftItem: DraftItem | undefined = undefined;

    onMount(() => {
        $event = thread;
    })

	afterUpdate(() => {
		$event = thread;
	});

	

	

	
	

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

	$: if ($pageHeader?.props) {
		$pageHeader.props.showAudience = false;

        switch ($view) {
            case 'edit':
                $pageHeader.props.showPublish = true;
                $pageHeader.props.showSchedule = true;
                $pageHeader.props.showPreview = true;
                $pageHeader.props.showSaveDraft = true;
                
                break;
            case 'view-preview':
                $pageHeader.props.shoEdit = true;
                $pageHeader.props.showPublish = true;
                $pageHeader.props.showSchedule = true;
                break;
        }
    }
</script>

<div class="max-w-3xl w-full sm:px-6 overflow-x-clip">
<Shell
	type="thread"
	on:prepare
	onSaveDraft={saveDraftNow}
	timedDraftSave={false}
>
	<UserProfile user={$currentUser} let:userProfile>
		{#each thread.items as item, i (i)}
			<!-- <ThreadItem
				bind:item
				bind:content={item.event.content}
				bind:urls={item.urls}
				{userProfile}
				shouldDisplayVerticalBar={true}
				autofocus={i === thread.items.length - 1}
				on:remove={() => removeItem(i)}
				on:submit={() => {thread.newItem(); thread.items = thread.items}}
				on:contentChanged={contentChanged}
			/> -->
		{/each}
		<div class="flex flex-col items-center flex-none w-10 sm:w-16 self-stretch">
			<button class="
				rounded-full p-2 text-foreground
				transition-all duration-300
				hover:!bg-accent
				hover:ring-8 ring-accent/30
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