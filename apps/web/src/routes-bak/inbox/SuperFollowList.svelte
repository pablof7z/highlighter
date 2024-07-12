<script lang="ts">
	import { NDKKind, type Hexpubkey } from '@nostr-dev-kit/ndk';
	import { userActiveSubscriptions, userFollows } from "$stores/session";
	import { MagicWand } from 'phosphor-svelte';
	import { page } from '$app/stores';
	import SuperFollowListItem from './SuperFollowListItem.svelte';
	import { ndk } from "$stores/ndk";
	import { derived } from 'svelte/store';

    export let mode: "all" | "paid" = "all";
    export let open: boolean;

    let selectedId: string;
    $: selectedId = $page.url.searchParams.get("id") || "";

    export let activeView = $userFollows;

    let allAuthors: Hexpubkey[] = [];

    allAuthors = Array.from($userFollows)

    const contentFromAllFollows = $ndk.storeSubscribe({
        kinds: [ NDKKind.Article, NDKKind.HorizontalVideo ],
        authors: allAuthors,
        limit: 5,
    });

    const pubkeysWithContent = derived(contentFromAllFollows, ($contentFromAllFollows) => {
        const pubkeys = new Set<string>();
        for (const content of $contentFromAllFollows) { pubkeys.add(content.pubkey); }
        return pubkeys;
    });

    $: if (mode === "all") {
        activeView = $pubkeysWithContent;
    } else if (mode === "paid") {
        // turn useractiveSubscriptions into a set
        const activeSubscriptions = new Set<string>();
        for (const subscription of $userActiveSubscriptions) {
            activeSubscriptions.add(subscription[0]);
        }

        activeView = activeSubscriptions;
    }
</script>

<a
    href="/inbox"
    class="justify-start items-center gap-2 inline-flex"
    class:active={selectedId === "" || selectedId === undefined}
    on:click={() => open = false}
>
    <div class="w-11 h-11 p-2.5 bg-zinc-800 rounded-[100px] justify-center items-center flex">
        <MagicWand class="w-5 h-5 relative flex-col justify-start items-start flex"></MagicWand>
    </div>
    <span class="text-right text-foreground text-[15px] font-medium name">All Feeds</span>
</a>
{#each activeView as pubkey (pubkey)}
    <button class="w-full" on:click={() => open = false}>
        <SuperFollowListItem {pubkey} {selectedId} />
    </button>
{/each}
