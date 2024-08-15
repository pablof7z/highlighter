<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { page } from "$app/stores";
    import { drafts, type DraftItem, DraftCheckpoint } from "$stores/drafts";
	import { ndk } from "$stores/ndk.js";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { goto } from "$app/navigation";
	import { onMount } from "svelte";
	import { Thread } from "$utils/thread";
	import ThreadEditor from "$components/Editor/ThreadEditor/ThreadEditor.svelte";
	import { layout } from '$stores/layout';
    import * as Content from '$components/Content';

    let draftId: string;
    let draftItem: DraftItem | undefined;
    let article: NDKArticle | undefined;
    let thread: Thread | undefined;
    let mounted = false;

    let checkpointTime: number | undefined;

    onMount(() => {
        mounted = true;
    });

    function fetchDrafItem(draftId: string) {
        if (!$currentUser) return;

        const time = $page.url.searchParams.get("checkpoint");
        if (time) checkpointTime = parseInt(time);

        if (draftId) {
            draftItem = $drafts.find(d => d.id === draftId);

            if (!draftItem) {
                goto("/drafts");
            } else {
                console.log({draftItem})
                
                const checkpoints = JSON.parse(draftItem.checkpoints) as DraftCheckpoint[];
                let checkpoint = checkpoints.find(c => c.manuallySaved);

                if (checkpointTime) {
                    checkpoint = checkpoints.find((c: DraftCheckpoint) => c.time === checkpointTime);
                }
                checkpoint ??= checkpoints[0];

                switch (draftItem.type) {
                    case "article": {
                        const payload = checkpoint?.data;
                        
                        article = new NDKArticle($ndk, JSON.parse(payload.event));
                        article.pubkey ??= $currentUser.pubkey;
                        article.author = $currentUser;

                        $layout.title = "Draft";
                        $layout.back = { url: "/drafts" }
                        $layout.navigation = [
                            { name: "Continue Editing", href: editUrl(draftItem) },
                            { name: !discarding ? "Discard" : "Confirm", buttonProps: { variant: "destructive" }, fn: discard }
                        ]
                        
                        break;
                    }
                    case "thread": {
                        const payload = checkpoint?.data as ThreadCheckpoint;
                        thread = Thread.deserialize(payload, $currentUser, $ndk);
                        break;
                    }
                }
            }
        }
    }

    function editUrl(item?: DraftItem) {
        if (!item) return "/drafts";
        const url = new URL("/studio/"+item.type, window.location.href);
        url.searchParams.set("draft", item.id);

        if (checkpointTime) {
            url.searchParams.set("checkpoint", checkpointTime.toString());
        }

        return url.toString();
    }
    
    $: if (draftItem) {
        $layout.navigation = [
            { name: "Continue Editing", href: editUrl(draftItem) },
            { name: !discarding ? "Discard" : "Confirm", buttonProps: { variant: "destructive" }, fn: discard }
        ]
    }

    let discarding = false;
    function discard() {
        if (!discarding)  {
            discarding = true;
            setTimeout(() => {
                discarding = false;
            }, 2000);
        } else {
        }
    }

    $: if (mounted && $currentUser) {
        draftId = $page.params.id;

        fetchDrafItem(draftId);
    }
</script>

{#key draftId + checkpointTime??""}
    {#if article}
        <Content.Shell
            wrappedEvent={article}
            let:wrappedEvent
            isPreview
        >
            <Content.Body event={wrappedEvent} />
        </Content.Shell>
    {:else if thread}
        <ThreadEditor bind:thread bind:draftItem />
    {/if}
{/key}