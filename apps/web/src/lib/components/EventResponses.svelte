<script lang="ts">
	import { NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
    import Comment from "./Forms/Comment.svelte";
	import { ndk } from "@kind0/ui-common";
	import RootReply from "./RepliesViewer/RootReply.svelte";
	import { onDestroy } from "svelte";
	import { slide } from "svelte/transition";

    export let event: NDKEvent;
    export let autofocusOnNewComment = false;

    const comments = $ndk.storeSubscribe([
        { kinds: [NDKKind.GroupNote], ...event.filter() },
    ], { subId: "comments", groupable: false });
    comments.onEose(() => fullyLoaded = true )

    let fullyLoaded = false;

    onDestroy(() => {
        comments.unref();
    })

    export let showComment = false;

    $: if (fullyLoaded && $comments.length === 0) {
        showComment = true;
    }

    function reset() {
        showComment = false;
    }
</script>

<div class="w-full">
    <div class="flex flex-row items-center justify-between w-full mb-8">
        <h1 class="text-white text-2xl font-semibold leading-8">Discussion</h1>
        <button class="button" on:click={() => showComment = !showComment}>Add your thoughts</button>
    </div>

    <!-- <pre>{JSON.stringify(comments.filters, null, 4)}</pre> -->

    {#if showComment}
        <div class="w-full" transition:slide>
            <Comment {event} on:published={reset} autofocus={autofocusOnNewComment} />
        </div>
    {/if}

    <div class="flex flex-col gap-6">
        {#each $comments as comment (comment.id)}
            <RootReply event={comment} />
        {/each}
    </div>
</div>