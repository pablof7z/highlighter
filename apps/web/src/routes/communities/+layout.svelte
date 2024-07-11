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

    $: groupId = $page.params.groupId ?? $page.url.searchParams.get('groupId');
</script>

{#if groupId}
    <Groups.Root
        {groupId}
        {relays}
        let:isMember
        let:isAdmin
        let:group
        let:metadata
        let:members
        let:admins
        let:tiers
    >
        <Groups.Shell {group} {isAdmin} {isMember} {metadata} {members} {admins} {tiers}>
            <slot />
        </Groups.Shell>
    </Groups.Root>
{:else}
    <slot />
{/if}