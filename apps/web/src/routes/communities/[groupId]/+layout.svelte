<script lang="ts">
	import { page } from "$app/stores";
	import GroupShell from "$views/Groups/GroupShelll.svelte";

    let groupId: string;
    let relays: string[];

    $: {
        const r = $page.url.searchParams.get('relays');
        if (r) {
            relays = r.split(',');
        }
    }

    $: groupId = $page.params.groupId;
</script>

<GroupShell {groupId} {relays}>
    <slot />
</GroupShell>