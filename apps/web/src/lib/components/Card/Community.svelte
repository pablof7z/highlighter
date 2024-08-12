<script lang="ts">
	import { NDKSimpleGroupMetadata, NDKHighlight, type NDKTag, NDKSubscriptionTier, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import ContentCard from "./ContentCard.svelte";
	import { Readable } from "svelte/store";
	import { Button } from "$components/ui/button";

    export let group: NDKSimpleGroup | undefined = undefined;
    export let groupId: string = group?.groupId!;
    export let relays: string[] = group?.relayUrls()!;
    export let metadata: Readable<NDKSimpleGroupMetadata | undefined>;
    export let isAdmin: Readable<boolean> | undefined = undefined;
</script>

    <ContentCard
        title={$metadata?.name??groupId}
        image={$metadata?.picture}
        description={$metadata?.about??relays.join(', ')}
        {...$$props}
        class="cursor-pointer"
        event={$metadata}
        alwaysShowPinButton={isAdmin && $isAdmin}
        on:click
    >
        <div class="flex flex-row gap-2">
            {#if $metadata?.access}
                <Button variant="secondary" size="xs">
                    Info
                </Button>
            {/if}
            <Button variant="accent" size="xs">
                Visit
            </Button>
        </div>
    </ContentCard>