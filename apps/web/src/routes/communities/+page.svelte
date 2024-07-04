<script lang="ts">
	import { loadedGroup } from "$stores/item-view";
	import Group from "$views/Groups/Group.svelte";
</script>

<Group group={$loadedGroup} />