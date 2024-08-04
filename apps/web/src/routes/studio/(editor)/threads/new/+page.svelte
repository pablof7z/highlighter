<script lang="ts">
	import UserProfile from '$components/User/UserProfile.svelte';
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { Thread } from "$utils/thread";
	import { NDKKind, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Writable } from "svelte/store";
    import ThreadItem from "$components/Editor/Thread/Item.svelte";
	import { Plus } from 'phosphor-svelte';
    import { Types as StudioItemTypes } from "$components/Studio";

    const thread = getContext("thread") as Writable<Thread | undefined>;
    const type = getContext("type") as Writable<StudioItemTypes>;
    $type = StudioItemTypes.Thread;

	$thread ??= new Thread(NDKKind.Text, $currentUser!, $ndk);
    
    let userProfile: NDKUserProfile | undefined = undefined;

    // const saveDraftNow = (manuallySaved: boolean) => {
	// 	const item = addDraftCheckpoint(
	// 		manuallySaved,
	// 		draftItem,
	// 		thread.serialize(),
	// 		"thread",
	// 	);
		
	// 	if (item) {
	// 		draftItem = item;
	// 		$drafts = $drafts;
	// 	}
	// }
    
    // const throttleSave = debounce(saveDraftNow, 2);
    
    // // Automatic saving triggers
	// function contentChanged() { throttleSave(false); }
	function contentChanged() { }
    
    function removeItem(i: number) {
		$thread.items.splice(i, 1);
		$thread.items = $thread.items;
		// throttleSave(false);
	}
</script>

<UserProfile user={$currentUser} let:userProfile />

<div class="my-10 responsive-padding">
    {#each $thread.items as item, i (i)}
        <ThreadItem
            bind:item
            bind:content={item.event.content}
            bind:urls={item.urls}
            {userProfile}
            shouldDisplayVerticalBar={true}
            autofocus={i === $thread.items.length - 1}
            on:remove={() => removeItem(i)}
            on:submit={() => {$thread.newItem(); $thread.items = $thread.items}}
            on:contentChanged={contentChanged}
        />
    {/each}
    <div class="flex flex-col items-center flex-none w-10 sm:w-16 self-stretch">
        <button class="
            rounded-full
            bg-secondary text-foreground
            max-sm:bg-accent max-sm:text-accent-foreground
            p-2 
            transition-all duration-300
            hover:!bg-accent
            hover:ring-8 ring-accent/30
        " on:click={() => { $thread.newItem(); $thread.items = $thread.items }}>
            <Plus size={24} weight="bold" />
        </button>
    </div>
</div>