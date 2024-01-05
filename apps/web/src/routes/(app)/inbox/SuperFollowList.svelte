<script lang="ts">
	import { userActiveSubscriptions, userSuperFollows } from "$stores/session";
	import { CaretDown, MagicWand } from 'phosphor-svelte';
	import { page } from '$app/stores';
	import SuperFollowListItem from './SuperFollowListItem.svelte';

    export let mode: "all" | "paid" = "all";
    export let open: boolean;

    let selectedId: string;
    $: selectedId = $page.url.searchParams.get("id") || "";

    // function resetFollow() {
    //     const event = new NDKEvent($ndk, {kind: 17001} as NostrEvent);
    //     event.publish();
    // }

    export let activeView = $userSuperFollows;

    $: if (mode === "all") {
        activeView = $userSuperFollows;
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
    <span class="text-right text-white text-[15px] font-medium name">All Feeds</span>
</a>
{#each activeView as pubkey (pubkey)}
    <button on:click={() => open = false}>
        <SuperFollowListItem {pubkey} {selectedId} />
    </button>
{/each}
