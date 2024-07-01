<script lang="ts">
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import currentUser from "$stores/currentUser";
	import { userFollows } from "$stores/session";
	import { ndk } from "$stores/ndk.js";
	import NDK, { NDKFilter, NDKKind, NDKEventId, NDKList } from "@nostr-dev-kit/ndk";

    export let type: "You" | "follows" = "You";

    const filters: NDKFilter[] = [ { kinds: [NDKKind.BookmarkList], limit: 50 } ]

    if (type === "follows") {
        filters[0].authors = Array.from($userFollows);
    } else if (type === "You") {
        filters[0].authors = [$currentUser!.pubkey];
    } else if (type === "recent") {
        const twoDaysAgo = Math.floor(Date.now() / 1000) - 2 * 24 * 60 * 60;
        filters[0].since = twoDaysAgo;
    }

    const listsSub = $ndk.subscribe(filters, { subId: 'lists', closeOnEose: true });
    listsSub.on("event", (event) => {
        const list = NDKList.from(event);
    });
    listsSub.on("eose", () => {
    });

    let eventFilters: NDKFilter[] | undefined = undefined;

    if (!eventFilters) {
        eventFilters = [];

        $ndk.fetchEvents(filters).then((events) => {
            console.log(`received ${events.size} events`)
            const map = new Map<NDKEventId, {count: number, tagType: string}>();

            for (const event of events) {
                const list = NDKList.from(event);
                console.log(`list ${list.id} has ${list.items.length} items`)

                for (const item of list.items) {
                    const val = map.get(item[1]) ?? { count: 0, tagType: item[0] };
                    val.count++;
                    map.set(item[1], val);
                }
            }

            const sortedIds = Array.from(map.entries())
                .filter(([id, {tagType}]) => tagType !== 'p')
                .sort((a, b) => b[1].count - a[1].count)
                .map(([id, {tagType}]) => [ tagType, id ])
                .slice(0, 100);

            const filter = new Map<string, Set<string>>();

            for (const [tagType, id] of sortedIds) {
                const currentSet = filter.get(tagType) ?? new Set<string>();
                currentSet.add(id);
                filter.set(tagType, currentSet);
            }

            let filters: NDKFilter[] = [];

            for (const [tagType, ids] of filter.entries()) {
                const filter: NDKFilter = {};
                if (tagType === "e") {
                    filter.ids = Array.from(ids);
                    eventFilters!.push(filter);
                }
            }

            eventFilters = eventFilters;
        }).catch((e) => {
            console.error(e);
        })
    }
</script>

{#if eventFilters && eventFilters.length > 0}
    <FilterFeed
        filters={eventFilters}
        urlPrefix="/e/"
        renderLimit={100}
    />
{:else}
    <div class="h-full flex flex-col gap-4 items-center justify-center">
        Loading Bookmarks, this will take a while
        <div>
            <span class="loading loading-lg loading-info"></span>
        </div>

    </div>
{/if}

