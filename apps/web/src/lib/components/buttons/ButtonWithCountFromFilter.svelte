<script lang="ts">
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKFilter, NDKSubscriptionOptions } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { Readable, get } from "svelte/store";
	import ButtonWithCount from "./ButtonWithCount.svelte";

    export let icon: typeof SvelteComponent;

    /**
     * e.g. hover:bg-green-400/20
     */
    export let bgHover: string;

    /**
     * e.g. text-[var(--boost-button)]/30 group-hover:text-[var(--boost-button)]
     */
    export let color: string;

    export let filters: NDKFilter[];
    export let subOpts: NDKSubscriptionOptions | undefined = undefined;
    export let isActiveFunc: (events: Readable<NDKEvent[]>) => boolean = (ev) => {
        if (!$currentUser) return false;
        const t = get(ev);
        return !!t.find(e => e.pubkey === $currentUser.pubkey) !== undefined;
    };

    subOpts ??= { subId : 'button-with-count', groupableDelay: 1000, groupableDelayType: "at-least" };

    export let events = $ndk.storeSubscribe(filters, subOpts);

    onDestroy(() => {
        events.unsubscribe();
    });

    export let isActive: boolean | undefined = undefined;

    $: isActive = isActiveFunc(events);
</script>

<ButtonWithCount
    class="rounded-full p-2 flex {bgHover}"
    count={$events.length}
    active={isActive}
    on:click
>
    {#if isActive}
        <svelte:component this={icon} class="sm:w-5 w-7 sm:h-5 h-7 {color}" weight="fill" />
    {:else}
        <svelte:component this={icon} class="sm:w-5 w-7 sm:h-5 h-7 {color}" weight="regular" />
    {/if}
</ButtonWithCount>