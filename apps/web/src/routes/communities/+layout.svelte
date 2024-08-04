<script lang="ts">
	import { page } from "$app/stores";
    import * as Groups from "$components/Groups";
	import { ndkRelaysWithAuth } from "$stores/auth-relays";
	import { layout } from "$stores/layout";

    let groupId: string;
    let relays: string[];

    $layout.back = { url: '/communities' };

    $: {
        const r = $page.url.searchParams.get('relays');
        if (r) {
            relays = r.split(',');

            for (const relay of relays) {
                $ndkRelaysWithAuth.set(relay, true);
            }
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
        let:stores
        let:joinRequests
        let:tiers
        let:admins
    >
        <Groups.Shell
            {group}
            {isAdmin}
            {isMember}
            {tiers}
            {joinRequests}
            {metadata}
            {members}
            {admins}
            {stores}
        >
            <slot />
        </Groups.Shell>
    </Groups.Root>
{:else}
    <slot />
{/if}