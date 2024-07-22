<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { eventToKind } from "$utils/event";
	import { NDKList } from "@nostr-dev-kit/ndk";
	import { onMount, setContext } from "svelte";
	import { derived } from "svelte/store";

    export let list: NDKList;

    const filters = list.filterForItems();
    const items = $ndk.storeSubscribe(filters, { groupable: false, closeOnEose: true, autoStart: false });

    onMount(() => items.startSubscription())

    const dedupedItems = Array.from(new Set(list.items));

    const orderedItems = derived(items, ($items) => {
        const res = [];

        for (const tag of dedupedItems) {
            const i = $items.find((item) => item.tagId() === tag[1]);
            if (i) {
                const k = eventToKind(i);
                res.push(eventToKind(i));
            }
        }

        return res;
    });

    setContext("items", orderedItems);
</script>

<slot {items} />
