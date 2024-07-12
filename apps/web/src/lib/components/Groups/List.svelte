<script lang="ts">
	import { NDKSimpleGroup } from "@nostr-dev-kit/ndk";
    import ListItem from "./ListItem.svelte";

    export let groups: Record<string, NDKSimpleGroup>;
    export let selectedGroups: Record<string, boolean>;
</script>

{#each Object.entries(groups) as [id, group]}
    {#if group.name}
        <ListItem
            {group}
            bind:selected={selectedGroups[id]}
        />
    {/if}
{/each}
