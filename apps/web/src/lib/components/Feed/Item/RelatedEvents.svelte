<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { wotFilteredStore } from "$stores/wot";
	import { deriveStore } from "$utils/events/derive";
	import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";
	import AvatarsPill from "$components/Avatars/AvatarsPill.svelte";
	import { ChatTeardrop, Lightning } from "phosphor-svelte";
	import { Badge } from "$components/ui/badge";

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
    <div class="flex flex-row items-start justify-start w-full gap-6 {$$props.class??""}">
        {#if $commentPubkeys.length}
            <Badge variant="secondary" class="p-0 gap-4">
                <ChatTeardrop weight="fill" size={16} class="text-muted-foreground ml-2" />
                <AvatarsPill pubkeys={$commentPubkeys} />
            </Badge>
        {/if}

        {#if $zapPubkeys.length}
            <Badge variant="secondary" class="p-0 gap-4">
                <Lightning weight="fill" size={16} class="text-muted-foreground ml-2" />
                <AvatarsPill pubkeys={$zapPubkeys} />
            </Badge>
        {/if}
    </div>
{/if}