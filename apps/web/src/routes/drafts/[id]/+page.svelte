<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { page } from "$app/stores";
    import { drafts, type ArticleCheckpoint, type DraftItem, DraftCheckpoint, ThreadCheckpoint } from "$stores/drafts";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
    import ArticleView from "$components/ArticleView.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { goto } from "$app/navigation";
	import { onMount } from "svelte";
	import { Thread } from "$utils/thread";
	import ThreadEditor from "$components/Editor/ThreadEditor/ThreadEditor.svelte";

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
                // goto("/drafts");
            } else {
                const checkpoints = JSON.parse(draftItem.checkpoints) as DraftCheckpoint[];
                let checkpoint = checkpoints.find(c => c.manuallySaved);

                if (checkpointTime) {
                    checkpoint = checkpoints.find((c: DraftCheckpoint) => c.time === checkpointTime);
                }
                checkpoint ??= checkpoints[0];

                switch (draftItem.type) {
                    case "article": {
                        const payload = checkpoint?.data as ArticleCheckpoint;

                        article = new NDKArticle($ndk, JSON.parse(payload.event));
                        article.pubkey ??= $currentUser.pubkey;
                        article.author = $currentUser;
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

    $: if (mounted && $currentUser) {
        draftId = $page.params.id;

        fetchDrafItem(draftId);
    }
</script>

{#key draftId + checkpointTime??""}
    {#if article}
        <a href="/articles/new?draft={draftId}" class="button text-lg">
            Continue editing
        </a>
        <ArticleView {article} isFullVersion={true} />
    {:else if thread}
        <ThreadEditor bind:thread bind:draftItem />
    {/if}
{/key}