<script lang="ts">
	import { page } from "$app/stores";
	import WithGroup from "$components/Event/WithGroup.svelte";
	import JoinGroupFooter from "$components/JoinGroupFooter.svelte";
	import { groupView, loadedGroup } from "$stores/item-view";
	import { pageHeader } from "$stores/layout";
	import { getGroupUrl } from "$utils/url";
	import { NavigationOption } from "../../app";
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
    <Groups.Shell {groupId} {relays}>
        <slot />
    </Groups.Shell>
{:else}
    <slot />
{/if}