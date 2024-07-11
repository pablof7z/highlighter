<script lang="ts">
	import { page } from "$app/stores";
    import * as Groups from "$components/Groups";

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

<Groups.Shell {groupId} {relays}>
    <slot />
</Groups.Shell>