<script lang="ts">
	import { page } from "$app/stores";
    import * as Groups from "$components/Groups";
	import { ndkRelaysWithAuth } from "$stores/auth-relays";
	import { layout } from "$stores/layout";
	import { NDKArticle, NDKEvent, NDKVideo, NDKWiki } from "@nostr-dev-kit/ndk";
	import { get, Readable } from "svelte/store";

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

    let group: Readable<Groups.GroupData> | undefined = undefined;
    let articles: Readable<NDKArticle[]>;
    let videos: Readable<NDKVideo[]>;
    let wiki: Readable<NDKWiki[]>;
    let notes: Readable<NDKEvent[]>;
    let chat: Readable<NDKEvent[]>;
</script>

{#if groupId}
    <Groups.Root
        {groupId}
        {relays}
        bind:group
        bind:articles
        bind:videos
        bind:chat
        bind:notes
        bind:wiki
    >
        <Groups.Shell
            {group}
            {articles}
            {videos}
            {chat}
            {notes}
            {wiki}
        >
            <slot />
        </Groups.Shell>
    </Groups.Root>
{:else}
    <slot />
{/if}