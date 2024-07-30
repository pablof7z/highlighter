<script lang="ts">
	import WithGroup from '$components/Event/WithGroup.svelte';
	import ReplyAvatars from '$components/Feed/ReplyAvatars.svelte';
	import RelativeTime from '$components/PageElements/RelativeTime.svelte';
	import currentUser from '$stores/currentUser';
	import { ndk } from '$stores/ndk';
	import { getGroupUrl } from '$utils/url';
    import { Hexpubkey, NDKArticle, NDKEvent, NDKFilter, NDKSimpleGroup, NDKTag } from '@nostr-dev-kit/ndk';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { derived, Readable } from 'svelte/store';
	import { groupsList, userFollows } from '$stores/session';
	import Swipe from '$components/Swipe.svelte';
	import AvatarsPill from '$components/Avatars/AvatarsPill.svelte';
	import { deriveStore } from '$utils/events/derive';
	import Badge from '$components/ui/badge/badge.svelte';
    export let tag: NDKTag;

    let group: NDKSimpleGroup;

    let recentEvents: NDKEventStore<NDKEvent>;
    let mostRecentEvent: Readable<NDKEvent | undefined>;

    function getLastTimeGroupWasChecked(group: NDKSimpleGroup) {
        // TODO
        return undefined;
    }

    let isMember: boolean | undefined;
    
    $: isMember = $currentUser ? group?.memberList?.hasMember($currentUser?.pubkey) : false;

    let pubkeysToFeature: Hexpubkey[] | undefined;

    $: if (group?.memberList && !isMember && !pubkeysToFeature) {
        pubkeysToFeature = [];
        for (const member of group.memberList.members) {
            if ($userFollows.has(member)) {
                pubkeysToFeature.push(member);
            }
        }
    }

    let recentArticles: Readable<NDKArticle[]>;

    $: if (group && isMember && !recentEvents) {
        const lastSeen = getLastTimeGroupWasChecked(group);
        const filters: NDKFilter[] = [{
            kinds: [1, 9, 10, 11, 12, 30023 ],
            "#h": [group.groupId]
        }];

        if (lastSeen) {
            // this makes sure we receive something in case there is nothing new
            filters.push({ ...filters[0], limit: 1, until: lastSeen })
            filters[0].since = lastSeen;
        }

        recentEvents = $ndk.storeSubscribe(
            filters,
            { subId: 'recent-group-events', closeOnEose: true, relaySet: group.relaySet },
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

        recentArticles = deriveStore(recentEvents, NDKArticle);
    }

    function pin(group: NDKSimpleGroup) {
        $groupsList?.addItem(["h", group.groupId, ...group.relayUrls()]);
        $groupsList?.publishReplaceable();
    }
    
    function unpin(groupId) {
        $groupsList?.removeItemByValue(groupId);
        $groupsList = $groupsList;
    }

    let rightOptions: [] = [];

    $: if (group) {
        rightOptions = [];
        if ($groupsList?.has(group.groupId))
            rightOptions.push({ label: 'Unpin', class: 'bg-secondary/50', cb: () => unpin(group.groupId) })
        else
            rightOptions.push({ label: 'Pin', class: 'bg-secondary/50', cb: () => pin(group) })
        if (isMember)
            rightOptions.push({ label: 'Leave', class: 'bg-secondary', cb: () => group?.leave() })
        else
            rightOptions.push({ label: 'Join', class: 'bg-secondary', cb: () => group?.join() })
    }
</script>

<WithGroup tag={tag} bind:group>
    {#if group && group.name}
        <Swipe {rightOptions}>
            <a href={getGroupUrl(group)} class="py-2 w-full group">
                <div class="responsive-padding flex flex-row items-center p-2 gap-4 w-full">
                    <img src={group.picture??`https://picsum.photos/24/24?random=${group.name}`} />
                    
                    <div class="flex flex-col gap-1 grow">
                        <span class="text-foreground font-semibold text-lg truncate">
                            {group.name??"Unnamed Group"}
                        </span>
                        {#if !isMember && pubkeysToFeature}
                            <AvatarsPill pubkeys={pubkeysToFeature} />
                        {:else if $mostRecentEvent}
                            <span class="text-sm text-muted-foreground truncate">
                                {$mostRecentEvent.content}
                            </span>
                        {:else if tag[2]}
                            <span class="text-xs text-muted-foreground truncate">
                                {tag[2]}
                            </span>
                        {/if}
                    </div>

                    {#if $recentArticles && $recentArticles.length > 0}
                        <Badge>
                            {$recentArticles.length}
                        </Badge>
                    {/if}
                    
                    {#if $mostRecentEvent}
                        <span>
                            <RelativeTime event={$mostRecentEvent} relative={true} />
                        </span>
                    {/if}

                    <div class="hidden lg:group-hover:flex">
                        {#if $groupsList?.has(group.groupId)}
                            <button on:click|stopPropagation|preventDefault={() => unpin(group.groupId)}>
                                unpin
                            </button>
                        {:else}
                            <button on:click|stopPropagation|preventDefault={() => pin(group)}>
                                pin
                            </button>
                        {/if}
                    </div>
                </div>
            </a>
        </Swipe>
    {/if}
</WithGroup>

<style lang="postcss">
    img {
        @apply w-12 h-12 rounded-full flex-none;
    }
</style>