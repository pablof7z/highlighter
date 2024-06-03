<script lang="ts">
	import { pageHeader } from "$stores/layout";
	import { NDKList, type NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";
	import { page } from '$app/stores';
	import { ndk } from "$stores/ndk";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import ListViewContent from './ListViewContent.svelte';
	import { CaretLeft } from 'phosphor-svelte';
	import { getAuthorUrl } from '$utils/url';

    export let event: NDKEvent;
    export let list = NDKList.from(event);
    export let urlPrefix: string | undefined = undefined;
    export let authorUrl: string | undefined = undefined;

    let id: string;

    $: id = $page.params.subId;

    if (!authorUrl) getAuthorUrl(list.author).then(url => authorUrl = url)

    const dTag = list.tagValue("d");

    $: if (dTag) {
        urlPrefix = [authorUrl, dTag ].join("/");
    } else {
        urlPrefix = `/a/${list.encode()}`
    }

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
    <ListViewContent
        {list}
        {urlPrefix}
    />
{/if}