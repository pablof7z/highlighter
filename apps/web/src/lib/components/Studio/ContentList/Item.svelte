<script lang="ts">
	import { Writable } from 'svelte/store';
	import { NDKArticle, NDKEvent, NDKVideo } from "@nostr-dev-kit/ndk";
    import { eventIsPreview } from "$utils/preview";
	import { nicelyFormattedMilliSatNumber } from "$utils";
	import PublishedToPills from "$components/Groups/PublishedToPills.svelte";
	import { eventKindToText } from "$utils/event";
	import { Lightning } from "phosphor-svelte";
    import * as Event from '$components/Event';
	import { getTotalZapAmount } from '$utils/zaps';

    export let event: NDKArticle | NDKVideo | NDKEvent;
    export let deletedItems: Writable<Set<string>>;

    const image = event instanceof NDKArticle ? event.image : event instanceof NDKVideo ? event.thumbnail : undefined;
    const title = (event instanceof NDKArticle || event instanceof NDKVideo) ? event.title : event.dTag;

    const zapAmount = getTotalZapAmount(event);
</script>

<div
    class="flex flex-row gap-4 items-center w-full hover:bg-secondary/20 transition-all duration-200 rounded"
>
    <div class="flex-none w-1/12">
        {#if image}
            <img src={image} class="w-16 h-16 rounded-sm object-cover flex-none" />
        {:else}
            <div class="w-16 h-16 bg-secondary rounded-sm flex-none" />
        {/if}
    </div>

    <div class="grow flex flex-col gap-1 col-span-4 overflow-clip justify-center">
        <a href="/a/{event.encode()}">
            {title}
            {#if eventIsPreview(event)}
                <div class="text-muted-foreground text-xs">(Preview version)</div>
            {/if}
        </a>
        <div class="w-fit">
            <PublishedToPills event={event} />
        </div>
    </div>

    <div class="w-1/12 flex flex-col items-center justify-center hidden">
        <!-- Views -->
        <div class="text-lg font-bold">{Math.floor(Math.random() * 1000)}</div>
        <div class="text-xs font-light text-muted-foreground">Views</div>
    </div>

    <div class="w-1/12 flex flex-col items-center justify-center" class:opacity-0={$zapAmount === 0}>
        <!-- Zaps -->
        <div class="text-lg font-bold flex flex-row items-center gap-1">
            <Lightning class="text-gold" size={20} weight="fill" />
            {nicelyFormattedMilliSatNumber(Math.floor($zapAmount))}
        </div>
        <div class="text-xs font-light text-muted-foreground">Zaps</div>
    </div>

    <div class="w-1/12 flex flex-row justify-end gap-2">
        <Event.Dropdown
            {event}
            on:delete={() => deletedItems.update(set => set.add(event.id))}
            on:delete:cancel={() => deletedItems.update(set => {set.delete(event.id); return set})}
        />
    </div>
</div>