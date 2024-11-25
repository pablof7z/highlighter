<script lang="ts">
	import { Readable } from 'svelte/store';
	import { NDKHighlight, type NDKTag, type NDKUserProfile, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { getGroupUrl } from "$utils/url";
	import FeaturedContentCard from "./FeaturedContentCard.svelte";
	import { Button } from "$components/ui/button";
	import { GroupData } from "$components/Groups";

    export let group: Readable<GroupData>;
</script>
{#if $group}
    <FeaturedContentCard
        event={$group.metadata}
        title={$group.name??"Untitled"}
        image={$group.picture}
        description={$group.about}
        alwaysShowPinButton
        {...$$props}
        href={getGroupUrl($group)}
    >
        <div class="flex flex-row items-center gap-2">
            <Button variant="accent" class="px-6 w-full">
                Visit
            </Button>
        </div>
    </FeaturedContentCard>
{/if}