<script lang="ts">
	import { onDestroy } from 'svelte';
	import { detailView, pageHeader, pageSidebar } from "$stores/layout";
	import { NDKList, type NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";
    import ListSidebar from "$components/PageSidebar/List.svelte";
	import { page } from '$app/stores';
	import { ndk } from '@kind0/ui-common';
	import ItemView from '../../routes/[id]/[tagId]/ItemView.svelte';
	import ListViewContent from './ListViewContent.svelte';
	import { CaretLeft } from 'phosphor-svelte';

    export let event: NDKEvent;
    export let list = NDKList.from(event);
    export let urlPrefix: string;
    export let authorUrl: string;

    let id: string;

    $: id = $page.params.subId;

    $detailView = {
        component: ListViewContent,
        props: { list, urlPrefix }
    }
    
    $pageSidebar = {
        component: ListSidebar,
        props: { list, urlPrefix }
    }

    $: $pageSidebar!.props.urlPrefix = urlPrefix;

    onDestroy(() => {
        pageSidebar.set(null);
    });

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

    $: if (id || !id) $pageHeader = {
        title: list.title,
        left: {
            icon: CaretLeft,
            url: authorUrl,
            label: "Lists"
        }
    }
</script>

{#if id}
    {#key id}
        <ItemView
            {user}
            tagId={id}
            mxClass="lg:mx-6"
            backUrl={urlPrefix}
            backTitle={list.title}
        />
    {/key}
{:else}
    <div class="lg:hidden">
        <ListViewContent
            {list}
            {urlPrefix}
        />
    </div>
{/if}