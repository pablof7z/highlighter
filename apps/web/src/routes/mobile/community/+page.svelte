<script lang="ts">
	import { page } from "$app/stores";
    import * as Groups from "$components/Groups";
	import { ndkRelaysWithAuth } from "$stores/auth-relays";
	import { layout } from "$stores/layout";

    let groupId: string;
    let relays: string[];
    let view: string;

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
    $: view = $page.url.searchParams.get('view') ?? 'home';
</script>

{#if groupId}
    <Groups.Root
        {groupId}
        {relays}
        let:group
    >
        <Groups.Shell
            {group}
        >
            {#if view === 'chat'}
                <Groups.Views.Chat {group} />
            {:else if view === 'posts'}
                <Groups.Views.Posts {group} />
            {:else if view === 'articles'}
                <Groups.Views.Articles {group} />
            {:else if view === 'settings'}
                <Groups.Views.Settings {group} existingTiers={tiers} {members} />
            {:else}
                <Groups.Views.Home {group} />
            {/if}
        </Groups.Shell>
    </Groups.Root>
{:else}
    <Groups.Views.Index />
{/if}