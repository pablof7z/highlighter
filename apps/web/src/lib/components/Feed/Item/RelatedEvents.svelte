<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { wotFilteredStore } from "$stores/wot";
	import { deriveListStore, deriveStore } from "$utils/events/derive";
	import { NDKEvent, NDKKind, NDKList } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";
	import AvatarsPill from "$components/Avatars/AvatarsPill.svelte";
	import { BookmarkSimple, ChatTeardrop, Lightning } from "phosphor-svelte";
	import { Badge } from "$components/ui/badge";
	import Avatar from "$components/User/Avatar.svelte";
	import Button from "$components/ui/button/button.svelte";

    export let event: NDKEvent;
    export let kinds: NDKKind[] = [
        NDKKind.Text,
        NDKKind.GroupChat, NDKKind.GroupNote, NDKKind.GroupReply,
        NDKKind.Nutzap, NDKKind.Zap,
        NDKKind.Repost, NDKKind.GenericRepost,
        NDKKind.Reaction,
        NDKKind.VideoCurationSet, NDKKind.ArticleCurationSet,
        NDKKind.Highlight
    ];

    const events = $ndk.storeSubscribe([
        { kinds, ...event.filter()}
    ], { subId: 'related-events', groupable: true, groupableDelay: 500 })
    const wotEvents = wotFilteredStore(events);

    const comments = deriveStore<NDKEvent>(wotEvents, undefined, [NDKKind.Text, NDKKind.GroupNote, NDKKind.GroupReply]);
    const commentPubkeys = derived(comments, $comments => Array.from(new Set($comments.map(c => c.pubkey))));

    const curations = deriveStore(events, NDKList, [NDKKind.ArticleCurationSet]);
    const nonSavedCurations = derived(curations, $curations => $curations.filter(c => c.dTag !== 'saved'));

    const zapPubkeys = derived(events, $events => {
        const z = new Set<string>();

        $events.forEach(e => {
            if (e.kind === NDKKind.Nutzap) {
                z.add(e.pubkey);
            } else if (e.kind === NDKKind.Zap) {
                const pTag = e.tagValue("P");
                if (pTag) z.add(pTag);
            }
        })
        
        return Array.from(z);
    });
</script>

{#if $wotEvents.length > 0}
    <div class="flex flex-row items-start justify-start gap-6 {$$props.class??""}">
        {#if $commentPubkeys.length}
            <Badge variant="secondary" class="p-1 gap-2">
                <ChatTeardrop weight="fill" size={16} class="text-foreground ml-2" />
                <div class="flex auto">
                    <AvatarsPill pubkeys={$commentPubkeys} size="xs" />

                </div>
            </Badge>
        {/if}

        {#if $zapPubkeys.length}
            <Badge variant="secondary" class="p-1 gap-2">
                <Lightning weight="fill" size={16} class="text-foreground ml-2" />
                <AvatarsPill pubkeys={$zapPubkeys} size="xs" />
            </Badge>
        {/if}

        {#if $nonSavedCurations.length > 0}
            {#if $nonSavedCurations.length > 1}
                <Badge variant="secondary" class="p-1 gap-2 items-center">
                    <BookmarkSimple weight="fill" size={16} class="text-foreground ml-2" />
                    <AvatarsPill pubkeys={$nonSavedCurations.map(c => c.pubkey)} size="xs" />
                    
                    <span class="whitespace-nowrap truncate font-light">{$nonSavedCurations[0].title}</span>
                </Badge>
            {:else}
                {#each $nonSavedCurations as c}
                    <Badge variant="secondary" class="p-1 gap-2 items-center">
                        <div class="flex gap-2 auto items-center">
                            <BookmarkSimple weight="fill" size={16} class="text-foreground ml-2" />
                            <Avatar pubkey={c.pubkey} size="xs" />
                            <span class="whitespace-nowrap truncate font-light">{c.title}</span>
                        </div>
                    </Badge>
                {/each}
            {/if}
        {/if}
    </div>
{/if}