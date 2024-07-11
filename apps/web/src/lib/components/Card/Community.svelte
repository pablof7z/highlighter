<script lang="ts">
	import { NDKSimpleGroupMetadata, NDKHighlight, type NDKTag, NDKSimpleGroup, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import ContentCard from "./ContentCard.svelte";

    export let group: NDKSimpleGroup;
    export let tag: NDKTag | undefined = undefined;
    export let highlights: NDKHighlight[] = [];
    export let tiers: NDKSubscriptionTier[] = [];
    export let metadata: NDKSimpleGroupMetadata | undefined = undefined;

    if (!metadata) group.getMetadata().then(m => metadata = m);
</script>

{#if metadata}
    <ContentCard
        title={metadata.name??"Unnamed"}
        image={metadata.picture}
        description={metadata.about}
        {...$$props}
    />
{/if}