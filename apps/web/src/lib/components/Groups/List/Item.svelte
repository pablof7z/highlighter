<script lang="ts">
	import * as Groups from "$components/Groups";
	import RelativeTime from '$components/PageElements/RelativeTime.svelte';
	import { getGroupUrl } from '$utils/url';
    import { Hexpubkey, NDKArticle, NDKEvent, NDKFilter, NDKKind } from '@nostr-dev-kit/ndk';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { derived, Readable } from 'svelte/store';
	import { groupsList, userFollows } from '$stores/session';
	import Swipe from '$components/Swipe.svelte';
	import AvatarsPill from '$components/Avatars/AvatarsPill.svelte';
	import Badge from '$components/ui/badge/badge.svelte';
	import { randomImage } from '$utils/image';
	import pinGroup from '$actions/Groups/pin';
	import { toast } from 'svelte-sonner';
	import { ndk } from '$stores/ndk';
	import { deriveStore } from '$utils/events/derive';
	import { goto } from '$app/navigation';
	import { lastSeenGroupTimestamp } from '$stores/notifications';
	import { NavigationOption } from "../../../../app";

    export let group: Readable<Groups.GroupData>;

    let recentEvents: NDKEventStore<NDKEvent>;
    let mostRecentEvent: Readable<NDKEvent | undefined>;

    function getLastTimeGroupWasChecked(): number | undefined {
        return $lastSeenGroupTimestamp[$group.id];
    }

    let pubkeysToFeature: Hexpubkey[] | undefined;

    $: if ($group.members && !$group.isMember && !pubkeysToFeature) {
        pubkeysToFeature = [];
        for (const member of $group.members.members) {
            if ($userFollows.has(member)) {
                pubkeysToFeature.push(member);
            }
        }
    }

    let unseenEvents: Readable<NDKEvent[]>;
    let unseenArticles: Readable<NDKArticle[]>;
    let unseenChats: Readable<NDKEvent[]>;

    $: if ($group.members && $group.isMember && !recentEvents) {
        const lastSeen = getLastTimeGroupWasChecked();
        const filters: NDKFilter[] = [{
            "#h": [$group.id]
        }];

        if (lastSeen) {
            // this makes sure we receive something in case there is nothing new
            filters.push({ ...filters[0], limit: 1, until: lastSeen })
            filters[0].since = lastSeen;
        }

        recentEvents = $ndk.storeSubscribe(
            filters,
            { subId: 'recent-group-events', groupable: false, relaySet: $group.relaySet },
        )

        mostRecentEvent = derived(recentEvents, $recentEvents => {
            if (!$recentEvents || $recentEvents.length === 0) return undefined;
            
            let choosenEvent: NDKEvent | undefined = $recentEvents[0];

            for (let i = 1; i < $recentEvents.length; i++) {
                if ($recentEvents[i].created_at! > choosenEvent.created_at!) {
                    choosenEvent = $recentEvents[i];
                }
            }

            return choosenEvent;
        })

        unseenEvents = derived(recentEvents, $recentEvents => {
            const lastTimeSeen = getLastTimeGroupWasChecked();
            if (!$recentEvents || lastTimeSeen === undefined) return $recentEvents;
            return $recentEvents.filter(e => e.created_at! > lastTimeSeen);
        });

        unseenArticles = deriveStore(unseenEvents, NDKArticle);
        unseenChats = deriveStore<NDKEvent>(unseenEvents, undefined, [NDKKind.GroupChat]);
    }

    function pin() {
        pinGroup($group.id, $group.relayUrls);
        toast.success('Group pinned');
    }
    
    function unpin() {
        $groupsList?.removeItemByValue($group.id);
        $groupsList = $groupsList;
    }

    let rightOptions: NavigationOption[] = [];

    $: if ($group) {
        rightOptions = [];
        if ($groupsList?.has($group.id))
            rightOptions.push({ name: 'Unpin', class: 'bg-secondary/50', fn: unpin })
        else
            rightOptions.push({ name: 'Pin', class: 'bg-secondary/50', fn: pin })
        rightOptions.push({ name: 'Visit', class: 'bg-secondary', fn: () => goto(getGroupUrl($group)) })
    }
</script>

<Swipe {rightOptions}>
    <a href={getGroupUrl($group)} class="py-1.5 group relative hover:bg-secondary transition-all duration-100 ease-in-out flex overflow-clip">
        <div class="responsive-padding flex flex-row items-stretch px-2 gap-3 w-full">
            <Groups.Avatar group={$group} size="small" />
            
            <div class="flex flex-col grow">
                <div class="flex flex-row gap-1 grow truncate justify-between items-center">
                    <span class="text-foreground font-medium text-base truncate">
                        <Groups.Name group={$group} />
                    </span>

                    <span class="text-xs text-muted-foreground whitespace-nowrap shrink">
                        {#if $mostRecentEvent}
                            <RelativeTime event={$mostRecentEvent} />
                        {/if}
                    </span>
                </div>

                <div class="flex flex-row gap-1 grow truncate items-center justify-between">
                    {#if !$group.isMember && $group.about}
                        <div class="text-sm lg:text-xs text-muted-foreground truncate">
                            {$group.about}
                        </div>
                    {/if}
                    {#if !$group.isMember && pubkeysToFeature}
                        <AvatarsPill pubkeys={pubkeysToFeature} />
                    {:else if $mostRecentEvent}
                        <span class="text-sm lg:text-xs text-muted-foreground truncate">
                            {$mostRecentEvent.content}
                        </span>
                    {:else if $group.about}
                        <div class="text-sm lg:text-xs text-muted-foreground truncate">
                            {$group.about}
                        </div>
                    {:else}
                        <div class="text-sm text-muted-foreground truncate">
                            {$group.relaySet.relayUrls[0]}
                        </div>
                    {/if}

                    <div class="flex flex-col items-end">
                        <div class="flex flex-row gap-2">
                            {#if $unseenArticles && $unseenArticles.length > 0}
                                <Badge class="whitespace-nowrap" variant="secondary">
                                    📚 {$unseenArticles.length}
                                </Badge>
                            {/if}
    
                            {#if $unseenEvents && $unseenEvents.length > 0}
                                <Badge class="whitespace-nowrap" variant="accent">
                                    {$unseenEvents.length}
                                </Badge>
                            {/if}
                        </div>
                    </div>
                </div>
            </div>

            <div class="hidden lg:group-hover:flex absolute top-0 right-0">
                {#if $groupsList?.has($group.id)}
                    <button on:click|stopPropagation|preventDefault={unpin}>
                        unpin
                    </button>
                {:else}
                    <button on:click|stopPropagation|preventDefault={pin}>
                        pin
                    </button>
                {/if}
            </div>
        </div>
    </a>
</Swipe>

<style lang="postcss">
    img {
        @apply w-12 h-12 rounded-full flex-none;
    }

    .grid > * {
        @apply bg-secondary;
    }
</style>