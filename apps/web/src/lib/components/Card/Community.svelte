<script lang="ts">
	import { NDKSimpleGroupMetadata, NDKHighlight, type NDKTag, NDKSubscriptionTier, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import ContentCard from "./ContentCard.svelte";
	import { Readable } from "svelte/store";
	import { Button } from "$components/ui/button";
    import * as Groups from "$components/Groups";
	import { getGroupUrl } from "$utils/url";

    export let group: Readable<Groups.GroupData>;
</script>

<ContentCard
    title={$group.name}
    href={getGroupUrl($group)}
    image={$group.picture}
    description={$group.about??$group.relayUrls.join(', ')}
    {...$$props}
    class="cursor-pointer"
    event={$group.metadata}
    alwaysShowPinButton={$group.isAdmin}
    on:click
>
    <div class="flex flex-row gap-2">
        <!-- {#if $metadata?.access}
            <Button variant="secondary" size="xs">
                Info
            </Button>
        {/if} -->
        <Button variant="accent" size="xs">
            Visit
        </Button>
    </div>
</ContentCard>