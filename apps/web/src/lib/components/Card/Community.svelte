<script lang="ts">
	import { NDKSimpleGroupMetadata, NDKHighlight, type NDKTag, NDKSimpleGroup, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import ContentCard from "./ContentCard.svelte";
	import { Readable } from "svelte/store";
	import { Button } from "$components/ui/button";
	import { getGroupUrl } from "$utils/url";
	import PinButton from "./Elements/PinButton.svelte";

    export let group: NDKSimpleGroup;
    export let tag: NDKTag | undefined = undefined;
    export let highlights: NDKHighlight[] = [];
    export let tiers: Readable<NDKSubscriptionTier[]>;
    export let metadata: Readable<NDKSimpleGroupMetadata | undefined>;
    export let isAdmin: Readable<boolean>;
</script>

{#if $metadata}
    <ContentCard
        title={$metadata.name??"Unnamed"}
        image={$metadata.picture}
        description={$metadata.about}
        {...$$props}
        class="cursor-pointer"
        event={$metadata}
        alwaysShowPinButton={$isAdmin}
        on:click
    >
        <div class="flex flex-row gap-2">
            {#if $metadata.access}
                <Button variant="secondary" size="xs">
                    Info
                </Button>
            {/if}
            <Button variant="accent" size="xs" href={getGroupUrl(group)}>
                Visit
            </Button>
        </div>
    </ContentCard>
{/if}