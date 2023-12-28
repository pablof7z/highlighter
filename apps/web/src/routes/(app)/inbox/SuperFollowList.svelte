<script lang="ts">
	import { userActiveSubscriptions, userSuperFollows } from "$stores/session";
	import { MagicWand } from 'phosphor-svelte';
	import { page } from '$app/stores';
	import SuperFollowListItem from './SuperFollowListItem.svelte';
	import { ChevronDown } from "lucide-svelte";

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

    let open = false;

    function toggleOpen() {
        open = !open;
    }
</script>

<div class="
    max-sm:w-full bg-base-100 max-sm:mobile-nav px-[var(--mobile-body-px)] py-2
    sm:w-[300px] sm:rounded-3xl sm:px-6 sm:pt-4 sm:pb-6
    border border-neutral-800 flex-col justify-start items-start gap-6 inline-flex shrink-0 {$$props.class??""}
">
    <div class="self-stretch justify-between items-center gap-6 inline-flex">
        <button
            class="flex flex-row items-center gap-4 justify-between"
            on:click={toggleOpen}
        >
            <div class="
                grow shrink basis-0 text-white font-semibold font-['Inter Display']
                max-sm:text-lg
                sm:text-2xl
            ">Inbox</div>

            <div class="sm:hiddden transition-all duration-500 sm:hidden" class:rotate-180={open}>
                <ChevronDown class="w-5 h-5 text-white" />
            </div>
        </button>
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

    <div
        class:max-sm:hidden={!open}
        class="
        max-sm:max-h-[50dvh]
        overflow-y-auto
        flex-col justify-center items-start gap-3 flex w-full
    ">
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