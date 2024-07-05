<script lang="ts">
	import { loadedGroup } from "$stores/item-view";
	import GroupPosts from "$views/Groups/GroupPosts.svelte";
</script>

{#if $loadedGroup}
    <GroupPosts group={$loadedGroup} />
{/if}