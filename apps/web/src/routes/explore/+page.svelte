<script lang="ts">
	import { NDKArticle, NDKEvent, NDKRelaySet } from '@nostr-dev-kit/ndk';
	import ArticleGrid from "$components/Events/ArticleGrid.svelte";
	import Navbar from "$components/Navbar.svelte";
    import { Avatar, Name, ndk } from "@kind0/ui-common";
	import { Article } from 'phosphor-svelte';
	import { onDestroy, onMount } from 'svelte';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import PostGrid from '$components/Events/PostGrid.svelte';
	import { defaultRelays } from '$actions/publishToTiers';

    let events: NDKEventStore<NDKEvent> | undefined = undefined;

    onMount(() => {
        const relaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);
        events = $ndk.storeSubscribe(
            { kinds: [30023], "#f": ["Free"] },
        { relaySet, autoStart: true, groupable: false, subId: 'explore' })
    });

    onDestroy(() => {
        events?.unsubscribe();
    })
</script>

<Navbar />

{#if events && $events}
    <div class="flex flex-col gap-6 w-full max-w-7xl mx-auto">

        <div class="w-full justify-between items-center inline-flex">
            <div class="justify-start items-start gap-6 inline-flex">
                <div class="text-white text-opacity-60 text-sm font-semibold leading-4">Popular Categories</div>
                <div class="text-white text-sm font-semibold leading-4">Art</div>
                <div class="text-white text-sm font-semibold leading-4">Bitcoin</div>
                <div class="text-white text-sm font-semibold leading-4">Philosophy</div>
                <div class="text-white text-sm font-semibold leading-4">Politics</div>
                <div class="text-white text-sm font-semibold leading-4">Sports</div>
                <div class="text-white text-sm font-semibold leading-4">NSFW</div>
            </div>
            <div class="justify-start items-center gap-4 inline-flex">
                <div class="text-white text-opacity-60 text-sm font-semibold leading-4">Sort by</div>
                <div class="justify-start items-center gap-1 flex">
                    <div class="p-2 bg-white bg-opacity-10 rounded-lg justify-start items-center gap-1.5 flex">
                        <div class="w-5 h-5 relative"></div>
                    </div>
                    <div class="p-2 rounded-lg justify-start items-center gap-1.5 flex">
                        <div class="w-5 h-5 relative"></div>
                    </div>
                    <div class="p-2 rounded-lg justify-start items-center gap-1.5 flex">
                        <div class="w-5 h-5 relative"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="w-full max-5xl">
            <div class="grid grid-cols-4 gap-10">
                {#each $events as event (event.id)}
                    {#if event.kind === 30023}
                        <ArticleGrid article={NDKArticle.from(event)} />
                    {:else if event.kind === 9}
                        <PostGrid {event} />
                    {/if}
                {/each}
            </div>
        </div>
    </div>
{/if}