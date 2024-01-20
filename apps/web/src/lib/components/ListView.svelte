<script lang="ts">
	import { onDestroy } from 'svelte';
	import { pageSidebar } from "$stores/layout";
	import { NDKList, type NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";
    import ListSidebar from "$components/PageSidebar/List.svelte";
	import { page } from '$app/stores';
	import { ndk } from '@kind0/ui-common';
	import ItemView from '../../routes/(app)/[id]/[tagId]/ItemView.svelte';

    export let event: NDKEvent;
    export let list = NDKList.from(event);
    export let urlPrefix: string;

    let id: string;

    $: id = $page.params.subId;

    $pageSidebar = {
        component: ListSidebar,
        props: { list, urlPrefix }
    }

    $: $pageSidebar!.props.urlPrefix = urlPrefix;

    onDestroy(() => {
        pageSidebar.set(null);
    });

    let eventToRender: NDKEvent;
    let user: NDKUser | null;

    $: {
        if (id) {
            const tag = list.items.find(tag => {
                const [ kind, pubkey, dTag ] = tag[1].split(":");
                return dTag === id || tag[1] === id;
            });

            if (tag) {
                const [ kind, pubkey, dTag ] = tag[1].split(":");

                if (pubkey) {
                    user = $ndk.getUser({pubkey});
                } else {
                    user = null;
                }
            }
        }
    }
</script>

{#if id}
    {#key id}
        <ItemView
            {user}
            tagId={id}
            mxClass="mx-6"
        />
    {/key}
{/if}
