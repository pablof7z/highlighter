<script lang="ts">
    import * as Content from "$components/Content";
	import { getContext } from "svelte";

    const event = getContext('wrappedEvent');
</script>
{#if [1, 11, 9802].includes(event.kind)}
    <Content.Comments />
{:else}
    <Content.Body />
{/if}