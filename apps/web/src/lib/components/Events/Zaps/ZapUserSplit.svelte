<script lang="ts">
    import { Name } from "@nostr-dev-kit/ndk-svelte-components";
    import Avatar from "$components/User/Avatar.svelte";
    import { ndk } from "$stores/ndk.js";
    import { nicelyFormattedSatNumber } from "$utils";

    export let pubkey: string | undefined = undefined;
    export let split: number = 60;
    export let totalSplitValue: number;
    export let totalSatsAvailable: number;
    export let satSplit: number;
    export let hideRange: boolean;

    const maxRange = totalSplitValue * 10;

    let percentage: number;

    $: percentage = (split / totalSplitValue)*100;
    $: satSplit = Math.floor((percentage * totalSatsAvailable)/100);
</script>

<div class="flex flex-row gap-2 justify-between items-center">
    <div
        class="flex flex-row justiry-start items-center gap-3 {!hideRange ? "w-1/2" : "w-full"}"
    >
        <Avatar {pubkey} class="w-12 h-12" />
        <div class="w-0 flex flex-col flex-grow">
            <span class="truncate whitespace-nowrap">
                <Name ndk={$ndk} {pubkey} class="text-base-100-content font-normal text-normal"/>
            </span>
            <span class="text-sm font-normal text-accent2">
                {Number.isNaN(satSplit) ? `0 sats` : `${nicelyFormattedSatNumber(satSplit)} sats`}
            </span>
        </div>
    </div>
    <div
        class="w-1/2"
        class:hidden={hideRange}
    >
        <input bind:value={split} type="range" min="0" max={maxRange} class="range range-accent range-xs" />
    </div>
</div>