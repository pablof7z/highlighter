<script lang="ts">
    import { ndk } from "$stores/ndk.js";
    import { NDKKind, NDKList, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { filterLists } from "$utils/curation-filter";
	import { CaretRight } from "phosphor-svelte";
	import { Badge } from "$components/ui/badge";
	import { pluralize } from "$utils";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";

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

<a href="/reads" class="flex flex-row justify-between max-sm:w-full py-2 responsive-padding z-10 bg-background border-b border-border">
    <div class="section-title">
        Collections
    </div>

    <CaretRight size={24} />
</a>

<div class="flex flex-col divide-y divide-border">
    <div class="py-[var(--section-vertical-padding)] w-full">
        <div class="flex flex-col">
            {#each $filteredCurations as list, index (list.id)}
                <div class="py-[var(--section-vertical-padding)] w-full">
                    <a href="/a/{list.encode()}" class="flex flex-col gap-2 group {$$props.class??""}">
                        {#if list.image}
                            <div class="relative px-4 py-3 flex flex-col items-start justify-end text-center overflow-clip rounded">
                                <img src={list.image} alt={list.title} class="w-full object-cover rounded-sm top-0 absolute left-0 grayscale right-0 bottom-0 opacity-40 group-hover:opacity-60 transition-all duration-300 ease-in-out" />
                                <h2 class="text-lg font-bold mb-0 max-sm:max-h-[3.5rem] overflow-y-clip relative">{list.title}</h2>

                                <div class="relative text-muted-foreground text-sm text-left pb-10">
                                    {list.description}
                                </div>

                                <div class="flex flex-row w-full justify-between relative text-muted-foreground">
                                    <AvatarWithName user={list.author} avatarSize="tiny" class="!text-[10px]" />

                                    <Badge variant="secondary" class="font-normal text-muted-foreground whitespace-nowrap">
                                        {list.items.length} {pluralize(list.items.length, "read")}
                                    </Badge>
                                </div>
                            </div>
                        {/if}
                    </a>
                </div>
            {/each}
        </div>
    </div>
</div>
