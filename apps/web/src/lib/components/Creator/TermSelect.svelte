<script lang="ts">
    import { possibleTerms } from "$utils/term";
	import type { NDKIntervalFrequency } from "@nostr-dev-kit/ndk";

    export let term: NDKIntervalFrequency;
</script>

<select class="select bg-base-200 text-white border border-base-300 flex-grow {$$props.class}" bind:value={term}>
    {#if !term}
        <option value="" selected>select interval {term}</option>
    {/if}
    {#each possibleTerms as term}
        <option value={term}>{term}</option>
    {/each}
</select>