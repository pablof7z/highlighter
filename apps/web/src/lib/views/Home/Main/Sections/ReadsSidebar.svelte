<script lang="ts">
    import { ndk } from "$stores/ndk.js";
    import { NDKKind, NDKList, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { filterLists } from "$utils/curation-filter";
	import { CaretRight } from "phosphor-svelte";
	import { Badge } from "$components/ui/badge";
	import { pluralize } from "$utils";

    onDestroy(() => {
        curations.unsubscribe();
    })

    const fourWeeksAgo = Math.floor(Date.now() / 1000) - 60 * 60 * 24 * 28;

    const relaySet = NDKRelaySet.fromRelayUrls([
        'wss://relay.primal.net',
        'wss://relay.highlighter.com',
        'wss://relay.f7z.io'
    ], $ndk);
    const curations = $ndk.storeSubscribe([
        { kinds: [NDKKind.ArticleCurationSet], limit: 50, since: fourWeeksAgo }
    ], {relaySet, closeOnEose: true}, NDKList);

    const filteredCurations = filterLists(curations);
</script>

<div class="flex flex-col divide-y divide-border">
    <div class="flex flex-col">
        {#each $filteredCurations as list, index (list.id)}
        <div class="py-[var(--section-vertical-padding)] w-full">
                <a href="/a/{list.encode()}" class="flex flex-col gap-2 group {$$props.class??""}">
                    {#if list.image}
                        <div class="relative px-4 py-3 flex flex-col items-start justify-end text-center overflow-clip rounded bg-black">
                            <img src={list.image} class="w-full object-cover rounded-sm top-0 absolute left-0 right-0 bottom-0 opacity-40 group-hover:opacity-60 transition-all duration-300 ease-in-out" />

                            <div class="flex flex-row justify-between w-full">
                                <h2 class="text-base font-medium mb-0 max-sm:max-h-[3.5rem] truncate overflow-y-clip relative text-left grow text-white">{list.title}</h2>
                                <Badge variant="secondary" class="font-normal whitespace-nowrap h-fit shrink text-white/80">
                                    {list.items.length} {pluralize(list.items.length, "read")}
                                </Badge>
                            </div>

                            <div class="relative text-white/50 font-light text-xs text-left">
                                {list.description}
                            </div>
                        </div>
                    {/if}
                </a>
            </div>
        {/each}
    </div>
</div>
