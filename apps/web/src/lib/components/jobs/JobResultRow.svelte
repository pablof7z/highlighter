<script lang="ts">
	import type { NDKDVMJobResult, NDKTag } from "@nostr-dev-kit/ndk";
    import ndk from "$stores/ndk";
    import EventCard from "./EventCard.svelte";
	import { EventContent, UserCard } from "@nostr-dev-kit/ndk-svelte-components";
	import { onMount } from "svelte";
	import { markEventAsSeen } from "$stores/notifications";
    import { Lightbox } from 'svelte-lightbox'

    export let event: NDKDVMJobResult;
    export let dontMarkAsSeen: boolean = false;
    export let expanded = false;

    function contentIsImageUrl() {
        try {
            const url = new URL(event.content);

            return url.pathname.endsWith(".png") ||
                url.pathname.endsWith(".jpg") ||
                url.pathname.endsWith(".jpeg");
        } catch (e) {
            return false;
        }
    }

    let tagsToDisplay = expanded ? 9999 : 3;
    let decodedContent: NDKTag[] | undefined;

    try {
        decodedContent = JSON.parse(event.content);
    } catch (e) {}

    let shouldRestrictResultHeight: boolean;

    shouldRestrictResultHeight =
        ( !contentIsImageUrl() &&
            event.jobRequest?.kind !== 65006
        ) || (
            decodedContent && decodedContent.length > tagsToDisplay
        ) || true;

    onMount(() => {
        if (!dontMarkAsSeen) markEventAsSeen(event.id);
    })
</script>

<div class="flex-grow overflow-x-clip
    {shouldRestrictResultHeight ? "overflow-y-hidden" : "overflow-y-auto "}
" class:max-h-48={shouldRestrictResultHeight}>
    {#if event.kind === 6100 && contentIsImageUrl()}
        <Lightbox>
            <img src={event.content} class={$$props.imageClass} />
        </Lightbox>
    {:else if event.jobRequest?.kind && [5300, 5301, 5302].includes(event.jobRequest?.kind)}
        {#if decodedContent}
            <div
                class="flex flex-col divide-y divide-base-300"
            >
                {#each decodedContent.slice(0, tagsToDisplay) as tag}
                    <div class="flex flex-row gap-4 p-2">
                        {#if tag[0] === "p"}
                            <UserCard ndk={$ndk} pubkey={tag[1]} class="" />
                        {:else if tag[0] === "e"}
                            {#await $ndk.fetchEvent(tag[1]) then event}
                                <EventCard
                                    ndk={$ndk}
                                    {event}
                                    class="flex-grow max-h-96 overflow-y-auto"
                                    dontMarkAsSeen={true}
                                >
                                    <EventContent ndk={$ndk} {event} showMedia={true} />
                                </EventCard>
                            {/await}
                        {:else}
                            {tag[1]}
                        {/if}
                    </div>
                {/each}

                {#if decodedContent.length > tagsToDisplay}
                    <button
                        class="absolute top-0 bottom-0 left-0 right-0 flex items-center justify-center bg-base-300 bg-opacity-40 group w-full rounded-box"
                        on:click={() => {
                            tagsToDisplay = decodedContent.length;
                            expanded = true;
                            shouldRestrictResultHeight = false;
                        }}
                    >
                        <div class="flex flex-row items-center justify-center p-2 pt-20">
                            <button
                                class="btn btn-ghost bg-base-300 !rounded-full group-hover:bg-base-200"
                                on:click={() => {
                                    tagsToDisplay = decodedContent.length;
                                    expanded = true;
                                    shouldRestrictResultHeight = false;
                                }}
                            >
                                {decodedContent.length} items
                            </button>
                        </div>
                    </button>

                    <div class="
                        flex flex-row justify-center p-2 absolute bottom-0 left-0 right-0
                        h-12
                        bg-gradient-to-t from-base-300 to-transparent
                    ">
                    </div>
                {/if}

            </div>
        {:else}
            {event.content}
        {/if}
    {:else}
        <EventContent ndk={$ndk} {event} showMedia={true} />
    {/if}
</div>