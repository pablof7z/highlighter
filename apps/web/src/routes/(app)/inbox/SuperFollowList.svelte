<script lang="ts">
	import { slide } from 'svelte/transition';
	import { userActiveSubscriptions, userSuperFollows } from "$stores/session";
	import { Avatar, Name } from "@kind0/ui-common";
	import { MagicWand } from 'phosphor-svelte';
	import { page } from '$app/stores';
	import SuperFollowListItem from './SuperFollowListItem.svelte';

    export let mode: "all" | "paid" = "all";

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

<div class="px-6 pt-4 pb-6 rounded-3xl border border-neutral-800 flex-col justify-start items-start gap-6 inline-flex w-[300px] shrink-0 {$$props.class??""}">
    <div class="self-stretch justify-start items-center gap-6 inline-flex">
        <div class="grow shrink basis-0 text-white text-2xl font-semibold font-['Inter Display']">Inbox</div>
        <div class="justify-start items-center flex">
            <div role="tablist" class="tabs tabs-boxed bg-transparent">
                <button
                    role="tab"
                    class="tab"
                    class:tab-active={mode === 'all'}
                    on:click={() => mode = 'all'}
                >All</button>
                <button
                    role="tab"
                    class="tab"
                    class:tab-active={mode === 'paid'}
                    on:click={() => mode = 'paid'}
                >Paid</button>
            </div>
        </div>
    </div>

    <div class="flex-col justify-center items-start gap-3 flex w-full">
        <a
            href="/inbox"
            class="justify-start items-center gap-2 inline-flex"
            class:active={selectedId === "" || selectedId === undefined}
        >
            <div class="w-11 h-11 p-2.5 bg-zinc-800 rounded-[100px] justify-center items-center flex">
                <MagicWand class="w-5 h-5 relative flex-col justify-start items-start flex"></MagicWand>
            </div>
            <span class="text-right text-white text-[15px] font-medium name">All Feeds</span>
        </a>
        {#each activeView as pubkey}
            <SuperFollowListItem {pubkey} {selectedId} />
        {/each}
        <!-- <button on:click={resetFollow} class="btn w-full btn-ghost">Reset</button> -->
    </div>
</div>

<style lang="postcss">
    .tab-active {
        @apply !bg-white !text-black;
    }

    a span.name {
        @apply text-opacity-60;
    }

    a.active span.name {
        @apply text-opacity-100;
    }
</style>