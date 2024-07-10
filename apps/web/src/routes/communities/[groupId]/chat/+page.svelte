<script lang="ts">
	import { loadedGroup } from "$stores/item-view";
	import GroupChat from "$views/Groups/GroupChat.svelte";
</script>

<div class="max-w-[var(--content-focused-width)] mx-auto w-full">
	<GroupChat group={$loadedGroup} />
</div>