<script lang="ts">
	import { NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
    import Comment from "./Forms/Comment.svelte";
	import { ndk } from "@kind0/ui-common";
	import RootReply from "./RepliesViewer/RootReply.svelte";
	import { onDestroy } from "svelte";
	import { slide } from "svelte/transition";
    import { createEventDispatcher } from "svelte";

    export let event: NDKEvent;
    export let autofocusOnNewComment = false;
    export let narrowView = false;

    const dispatch = createEventDispatcher();

    const comments = $ndk.storeSubscribe([
        { kinds: [NDKKind.GroupNote], ...event.filter() },
    ], { subId: "comments", groupable: false });
    comments.onEose(() => fullyLoaded = true )

    let fullyLoaded = false;

    onDestroy(() => {
        comments.unref();
    })

    export let showComment = false;

    function reset() {
        showComment = false;
    }

    $: if (narrowView) showComment = true;
</script>

<div class="w-full {$$props.class??""}">
    <div class="flex flex-row items-center justify-between w-full mb-8">
        <h1 class="text-white text-2xl font-semibold leading-8">Discussion</h1>
        {#if !narrowView}
            <button class="button" on:click={() => showComment = !showComment}>Add your thoughts</button>
        {/if}
    </div>

    <!-- <pre>{JSON.stringify(comments.filters, null, 4)}</pre> -->

    {#if showComment}
        <div class="w-full" transition:slide>
            <Comment
                {narrowView}
                {event}
                on:published={reset}
                on:focus={() => dispatch("comment:focus")}
                on:blur={() => dispatch("comment:blur")}
            />
        </div>
    {/if}

    <div class="flex flex-col gap-6">
        {#each $comments as comment (comment.id)}
            <RootReply event={comment} />
        {/each}
    </div>
</div>