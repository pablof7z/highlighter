<script lang="ts">
    import { NDKEvent } from "@nostr-dev-kit/ndk";
    import Time from "svelte-time";
	import { onDestroy } from 'svelte';

    export let event: NDKEvent | undefined = undefined;
    export let relative = true;
    export let format: string | undefined = undefined;

    let published_at = event?.tagValue("published_at");

    /**
     * Timestamp to display
     */
    export let timestamp: number | undefined = (published_at ? parseInt(published_at) : event?.created_at)! * 1000;


    /**
     * Force-correct events/timestamps that are using milliseconds
     */
    if (timestamp > 1494887682700000) timestamp /= 1000;

    /**
     * Number of seconds to use relative time for.
     */
    export let timeAgoCutoff: number = 60*60*24;

    function useRelativeTime() {
        if (!relative) return false;

        const now = Date.now();
        const diff = now - timestamp;

        if (!format) {
            // if less than a minute, show "just now"
            if (diff < 60000) format = "just now";
            // if less than an hour, show minutes
            else if (diff < 3600000) format = "mm'm' ago";
            // if less than a day, show hours
            else if (diff < 86400000) format = "h[h]";
            // if less than a week, show days
            else if (diff < 604800000) format = "dd'd' ago";
        }

        return diff < 1000 * timeAgoCutoff;
    }

    const updateDiff = () => { distanceOfTime = timestamp ? Math.floor((Date.now() - timestamp) / 1000) : 99999999; }

    let distanceOfTime: number = 99999999;
    updateDiff();
    const interval = setInterval(updateDiff, 5000);

    onDestroy(() => {
        clearInterval(interval);
    });


</script>

{#if !Number.isNaN(timestamp)}
    {#if distanceOfTime < 60}
        <span class={$$props.class || ``}>
            just now
        </span>
    {:else if distanceOfTime < 60 * 60}
        <span class={$$props.class || ``}>
            {Math.floor(distanceOfTime/60)}m
        </span>
    {:else if distanceOfTime < 60 * 60 * 24}
        <span class={$$props.class || ``}>
            {Math.floor(distanceOfTime/60/60)}h
        </span>
    {:else if distanceOfTime < 60 * 60 * 24 * 30}
        <span class={$$props.class || ``}>
            {Math.floor(distanceOfTime/60/60/24)}d
        </span>
    {:else}
        <Time
            live={true}
            {timestamp}
            class={$$props.class || ``}
            format="M/D/YY"
        />
    {/if}
{/if}