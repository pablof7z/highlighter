<script lang="ts">
    import { ndk } from "$stores/ndk.js";
import currentUser from "$stores/currentUser.js";
	import CreatorActivityItem from "./CreatorActivityItem.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { onDestroy } from "svelte";
	import Tab from "$components/Tab.svelte";
	import { derived, type Readable } from "svelte/store";
	import { NDKKind, type NDKEvent, type NDKEventId } from "@nostr-dev-kit/ndk";
	import SubscriptionStart from "./ActivityItems/SubscriptionStart.svelte";
	import HighlightCreated from "./ActivityItems/HighlightCreated.svelte";
	import SubscriptionZapReceived from "./ActivityItems/SubscriptionZapReceived.svelte";
	import SupporterList from "$components/Supporters/SupporterList.svelte";

    const events = $ndk.storeSubscribe([
        { kinds: [
            11,
            12,
            9802,
            NDKKind.Reaction,
            NDKKind.Repost, NDKKind.GenericRepost,
        ], "#h": [$user?.pubkey] },
        { kinds: [ 7001, 7002, 7003 ], "#p": [$user?.pubkey] },
        { kinds: [ NDKKind.Zap ], "#p": [$user?.pubkey] },
    ]);
    let eventsToRender: Readable<NDKEvent[]>;
    let subStartEventIds: Readable<Set<NDKEventId>>;

    onDestroy(() => {
        events.unsubscribe();
    })

    let authorUrl: string;
    let selection: string = "Everything";

    const withoutOwnEvents = (event: NDKEvent) => event.author?.pubkey !== $user?.pubkey;

    const withoutUnrelatedZaps = (event: NDKEvent, subStartEventIds: Set<NDKEventId>) => {
        if (event.kind !== NDKKind.Zap) return true;
        const eTag = event.tagValue("e");
        if (!eTag) return false;
        return subStartEventIds.has(eTag);
    }

    subStartEventIds = derived([events], ([$events]) => {
        const subStartEventIds = new Set<NDKEventId>();
        for (const event of $events) {
            if (event.kind === 7001) subStartEventIds.add(event.id);
        }
        return subStartEventIds;
    });

    $: if (selection) {
        eventsToRender = derived([
            events, subStartEventIds
        ], ([$events, $subStartEventIds]) => {
            let kinds: number[] = [];
            switch (selection) {
                case "Replies": kinds = [11, 12]; break;
                case "Earnings": kinds = [7001, 7002, 7003, 9735]; break;
                case "Dissemination": kinds = [NDKKind.Repost, NDKKind.GenericRepost, NDKKind.Highlight, NDKKind.Reaction]; break;
                default:
                    return $events
                        .filter(withoutOwnEvents)
                        .filter((e) => withoutUnrelatedZaps(e, $subStartEventIds))
            }

            return $events
                .filter((event: NDKEvent) => kinds.includes(event.kind!))
                .filter(withoutOwnEvents)
                .filter((e) => withoutUnrelatedZaps(e, $subStartEventIds))
        });
    }
</script>

<UserProfile user={$user} bind:authorUrl />

<div role="tablist" class="tabs tabs-boxed w-full sm:w-fit">
    <Tab title="Everything" bind:value={selection} class="pill"></Tab>
    <Tab title="Replies" bind:value={selection} class="pill"></Tab>
    <Tab title="Earnings" bind:value={selection} class="pill"></Tab>
    <Tab title="Dissemination" bind:value={selection} class="pill"></Tab>
</div>

<div class="flex flex-col gap-10">
    <div class="flex flex-col items-stretch bg-foreground/10 rounded divide-y divide-base-300">
        {#each $eventsToRender as event (event.id)}
            <div class="p-6 flex flex-col items-stretch">
                {#if event.kind === 7001}
                    <SubscriptionStart {event} />
                {:else if event.kind === NDKKind.Highlight}
                    <HighlightCreated {event} />
                {:else if event.kind === NDKKind.Zap}
                    <SubscriptionZapReceived {event} />
                {:else}
                    <CreatorActivityItem {event} creatorUrl={authorUrl} />
                {/if}
            </div>
        {/each}

        {#if $eventsToRender.length === 0}
            <div class="text-foreground text-opacity-60 font-normal leading-5">
                No activity yet
            </div>
        {/if}
    </div>
</div>