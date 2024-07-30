<script lang="ts">
	import { NDKHighlight, type NDKTag, type NDKUserProfile, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { getGroupUrl } from "$utils/url";
	import FeaturedContentCard from "./FeaturedContentCard.svelte";
	import { Button } from "$components/ui/button";

    export let group: NDKSimpleGroup;
    export let tag: NDKTag | undefined = undefined;

    const metadata = group.metadata;
</script>

{#if metadata}
    <FeaturedContentCard
        event={metadata}
        title={metadata.name??"Untitled"}
        image={metadata.picture}
        description={metadata.about}
        alwaysShowPinButton
        {...$$props}
        href={getGroupUrl(group)}
    >
        <div class="flex flex-row items-center gap-2">
            <Button variant="accent" class="px-6 w-full">
                Visit
            </Button>
        </div>
    </FeaturedContentCard>
{/if}