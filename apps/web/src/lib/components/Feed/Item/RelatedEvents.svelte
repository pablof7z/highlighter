<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { wotFilteredStore } from "$stores/wot";
	import { deriveStore } from "$utils/events/derive";
	import { Hexpubkey, NDKEvent, NDKHighlight, NDKKind, NDKList } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";
	import AvatarsPill from "$components/Avatars/AvatarsPill.svelte";
	import { BookmarkSimple, ChatTeardrop, Lightning, Recycle, Repeat, Share } from "phosphor-svelte";
	import { Badge } from "$components/ui/badge";
	import Avatar from "$components/User/Avatar.svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";

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

    const curations = deriveStore(events, NDKList, [NDKKind.ArticleCurationSet]);
    const nonSavedCurations = derived(curations, $curations => $curations.filter(c => c.dTag !== 'saved'));

    type Actions = 'comment' | 'highlight' | 'zap' | 'curation' | "repost";
    
    const actions = derived(wotEvents, $wotEvents => {
        const actions = new Set<Actions>();
        const pubkeys = new Set<Hexpubkey>();

        for (const event of $wotEvents) {
            let action: Actions | undefined;
            let pubkey: Hexpubkey | undefined = event.pubkey;

            switch (event.kind) {
                case NDKKind.Zap: {
                    const pTag = event.tagValue("P");
                    if (pTag) {
                        action = 'zap';
                        pubkey = pTag;
                    } else {
                        action = undefined;
                        pubkey = undefined;
                    }
                    break;
                }
                case NDKKind.Nutzap: action = 'zap'; break;
                case NDKKind.Text: case NDKKind.GroupNote: case NDKKind.GroupReply: action = 'comment'; break;
                case NDKKind.Highlight: action = 'highlight'; break;
                case NDKKind.Repost: case NDKKind.GenericRepost: action = 'repost'; break;
            }

            if (action && pubkey) {
                actions.add(action);
                pubkeys.add(pubkey);
            }
        }

        return { types: Array.from(actions), pubkeys: Array.from(pubkeys) };
    });

    const byPubkeys = derived(wotEvents, $events => {
        const byPubkey = new Set<Hexpubkey>();
        $events.forEach(e => {
            if (e.kind === NDKKind.Zap) {
                const pTag = e.tagValue("P");
                if (pTag) byPubkey.add(pTag);
            } else {
                byPubkey.add(e.pubkey);
            }
        });
        return Array.from(byPubkey);
    });
</script>

{#if $actions.types.length > 0}
    <Badge variant="secondary" class="p-1 gap-4 items-center w-fit">
        <div class="flex flex-row space-x-2 pl-2">
            {#each $actions.types as action}
                {#if action === 'comment'}
                    <ChatTeardrop weight="fill" size={16} class="text-foreground" />
                {:else if action === 'repost'}
                    <Repeat size={16} class="text-foreground" />
                {:else if action === 'highlight'}
                    <HighlightIcon weight="fill" size={16} class="text-foreground w-4 h-4" />
                {:else if action === 'zap'}
                    <Lightning weight="fill" size={16} class="text-foreground" />
                {:else if action === 'curation'}
                    <BookmarkSimple weight="fill" size={16} class="text-foreground" />
                {/if}
            {/each}
        </div>
        
        <AvatarsPill pubkeys={$actions.pubkeys} size="xs" />

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
    </Badge>
{/if}