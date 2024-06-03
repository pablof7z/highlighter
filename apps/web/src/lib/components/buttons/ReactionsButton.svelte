<script lang="ts">
	import { ndk } from "$stores/ndk.js";
import currentUser from "$stores/currentUser.js";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { openModal } from '$utils/modal';
	import { ChatCircle } from 'phosphor-svelte';
	import UserProfile from "$components/User/UserProfile.svelte";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";

    export let event: NDKEvent;

    const responses = $ndk.storeSubscribe(
        { kinds: [1, 12], ...event.filter() },
        {
            cacheUsage: NDKSubscriptionCacheUsage.PARALLEL,
            groupableDelay: 100,
            groupableDelayType: "at-least",
        }
    );

    onDestroy(() => {
        responses.unref();
    });

    let commentedByUser = false;

    function findUserComment(r: NDKEvent) {
        return r.pubkey === $user?.pubkey;
    }

    $: commentedByUser = !!$responses.find(findUserComment);

    let authorUrl: string;
    let eventSuffix = urlSuffixFromEvent(event);

    const url = new URL(window.location.href);
    $: url.pathname = `/${authorUrl}/${eventSuffix}/comments`;
</script>

<UserProfile user={event.author} bind:authorUrl />

<a
    href={url.toString()}
    class="flex flex-row items-center gap-2 {commentedByUser ? 'text-white' : ''}"
>
    <ChatCircle
        class="w-7 h-7"
        weight={commentedByUser ? "fill" : "regular"}
    />

    <span class="font-light opacity-60">
        {#if $responses.length > 0}
            {$responses.length}
        {:else}
            Comments
        {/if}
    </span>
</a>