<script lang="ts">
	import { NDKKind, type NDKEvent, NDKUser, type Hexpubkey, type NDKFilter } from "@nostr-dev-kit/ndk";
    import Comment from "./Forms/Comment.svelte";
	import { ndk, user } from "@kind0/ui-common";
	import RootReply from "./RepliesViewer/RootReply.svelte";
	import { onDestroy } from "svelte";
	import { slide } from "svelte/transition";
    import { createEventDispatcher } from "svelte";
	import { userActiveSubscriptions } from "$stores/session";
	import { canUserComment, requiredTiersFor } from "$lib/events/tiers";
	import UpgradeButton from "./buttons/UpgradeButton.svelte";
    import createDebug from "debug";

    export let event: NDKEvent;
    export let autofocusOnNewComment = false;
    export let narrowView = false;

    const debug = createDebug("highlighter:responses");
    const dispatch = createEventDispatcher();

    // Ids for filter
    const filters: NDKFilter[] = [{ kinds: [NDKKind.GroupNote], ...event.filter() }]
    const counterpartEvent = event.tagValue("full") || event.tagValue("preview");

    if (counterpartEvent) {
        filters.push({ kinds: [NDKKind.GroupNote], "#a": [counterpartEvent] });
    }

    filters.push({
        kinds: [NDKKind.Text, NDKKind.GroupReply],
        ...event.filter()
    })

    debug(filters);

    const comments = $ndk.storeSubscribe(filters, { subId: "comments", groupable: false });
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

    let canComment = false;

    $: if (event && $userActiveSubscriptions) {
        canComment = canUserComment(event, $user, $userActiveSubscriptions)
    }

    function toggleCommentBox() {
        if (!canComment) {
            alert("You need to be subscribed to this creator to comment");
            return;
        }
        showComment = !showComment;
    }
</script>

<div class="w-full {$$props.class??""}">
    <!-- <div class="flex flex-row items-center justify-end w-full mb-8"> -->
        <!-- {#if !narrowView}
            {#if canComment}
                <button class="button" on:click={toggleCommentBox}>Add your thoughts</button>
            {:else}
                <UpgradeButton {event} text="Join to comment" />
            {/if}
        {/if} -->
    <!-- </div> -->

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

    <div class="flex flex-col gap-6 discussion-wrapper bg-black/90">
        {#each $comments as comment (comment.id)}
            <RootReply event={comment} />
        {/each}
    </div>
</div>