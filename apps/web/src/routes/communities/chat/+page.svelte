<script lang="ts">
	import { loadedGroup } from "$stores/item-view";
	import GroupChat from "$views/Groups/GroupChat.svelte";
</script>

<GroupChat group={$loadedGroup} />