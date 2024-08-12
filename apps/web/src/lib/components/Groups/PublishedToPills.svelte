<script lang="ts">
    /**
     * This component renders a small list of the groups where an event has been published to.
     */
	import { NDKEvent } from "@nostr-dev-kit/ndk";
    import * as Groups from "$components/Groups";
	import { getGroupUrl } from "$utils/url";

    export let event: NDKEvent;

    const tags = event.getMatchingTags("h");

    const groups = Groups.loadGroupsData(tags);

    let href: string | undefined;

    $: if (Object.keys($groups).length === 1) {
        href = getGroupUrl(Object.values($groups)[0]);
    }
</script>

{#if $groups && Object.keys($groups).length > 0}
    <a {href} class="flex flex-row gap-2 font-thin text-muted-foreground items-center" size="xs">
        <div class="-space-x-2">
            {#each Object.values($groups) as group}
                <Groups.Avatar {group} size="xs" />
            {/each}
        </div>

        {#if Object.keys($groups).length > 1}
            <span class="text-xs">+{tags.length - 1}</span>
        {:else if Object.keys($groups).length === 1}
            <div class="text-xs">
                {Object.values($groups)[0].name}
            </div>
        {/if}
    </a>
{/if}