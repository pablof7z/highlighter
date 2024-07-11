<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext } from 'svelte';
	import { Readable } from 'svelte/store';
    import { NDKArticle, NDKSimpleGroup } from "@nostr-dev-kit/ndk";

    const userGroups = getContext('userGroups') as Readable<Record<string, NDKSimpleGroup>>;
</script>

<div class="responsive-padding">
    {#each Object.entries($userGroups) as [groupId, group] (groupId)}
        <p>{groupId}</p>
        {group.picture}
    {/each}
</div>