<script lang="ts">
	import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { openModal } from "svelte-modals";
	import { ChatCircle } from 'phosphor-svelte';
	import UserProfile from "$components/User/UserProfile.svelte";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";

    export let event: NDKEvent;
    export let urlPrefix: string;

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
</script>

<a
    href="{urlPrefix}/comments"
    class="flex flex-row items-center gap-2 {commentedByUser ? 'text-white' : ''}"
>
    <ChatCircle
        class="w-7 h-7"
        weight={commentedByUser ? "fill" : "regular"}
    />

    {#if $responses.length > 0}
        <span class="font-light opacity-60">
            {$responses.length}
        </span>
    {/if}
</a>