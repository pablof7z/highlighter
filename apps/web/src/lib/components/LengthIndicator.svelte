<script lang="ts">
    export let text: string;
    export let maxLength = 140;
    export let overText = "How about a thread?";

    function computeLength(text: string) {
        // count URLs are 1 character, anything that starts with nostr:n is 1 character
        // trim it
        let trimmed = text.trim();
        trimmed = trimmed.replace(/https?:\/\/[^\s]+/g, "x");
        trimmed = trimmed.replace(/nostr:n[^\s]+/g, "x");
        return trimmed.length;
    }

    let length: number;
    let percentage: number;

    $: length = computeLength(text);
    $: percentage = Math.min(100, (length / maxLength) * 100);
</script>

{#if length > 0}
    {#if length > maxLength}
        <div class="text-accent2 text-xs">{overText}</div>
    {/if}

    <div class:text-accent2={percentage > 80} class="radial-progress" style="--value:{percentage}; --size:2rem; --thickness:2px;" role="progressbar">
        <span class="text-xs font-light">{length}</span>
    </div>
{/if}