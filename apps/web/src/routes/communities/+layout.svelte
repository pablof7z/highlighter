<script lang="ts">
	import { page } from "$app/stores";
    import * as Groups from "$components/Groups";
	import { ndkRelaysWithAuth } from "$stores/auth-relays";
	import { layout } from "$stores/layout";

    let groupId: string;
    let relays: string[];

    $: {
        const r = $page.url.searchParams.get('relays');
        if (r) {
            relays = r.split(',');

            for (const relay of relays) {
                $ndkRelaysWithAuth.set(relay, true);
            }
        }
    }

    $: {
        groupId = $page.params.groupId ?? $page.url.searchParams.get('groupId');
        $layout.back = { url: groupId ? '/communities?'+groupId : '/' };
    }
</script>

{#if groupId}
    <Groups.Root
        {groupId}
        {relays}
        let:group
        let:articles
        let:videos
        let:wiki
        let:notes
        let:chat
        let:tiers
    >
        <Groups.Shell
            {group}
            {articles}
            {videos}
            {wiki}
            {notes}
            {chat}
            {tiers}
        >
            <slot />
        </Groups.Shell>
    </Groups.Root>
{:else}
    <slot />
{/if}