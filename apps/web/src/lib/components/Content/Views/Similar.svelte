<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { ndk } from "$stores/ndk";
	import { getEventUrl } from "$utils/url";
	import { NDKArticle, NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";

    export let wrappedEvent: NDKEvent;

    const otherEntries = $ndk.storeSubscribe({
        kinds: [NDKKind.Wiki], "#d": [wrappedEvent.dTag!]
    }, undefined, NDKArticle);

    const dTag = wrappedEvent.dTag!;
</script>

<h1>{dTag}</h1>

<div class="flex flex-col gap-2">
    {#each $otherEntries as entry (entry.id)}
        <a href={getEventUrl(entry)} class="rounded p-3 w-full">
            <div class="inline">
                <AvatarWithName href={getEventUrl(entry)} pubkey={entry.pubkey} avatarSize="tiny" />
            </div>
        </a>
    {/each}
</div>