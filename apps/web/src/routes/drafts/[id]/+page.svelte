<script lang="ts">
	import { page } from "$app/stores";
    import { drafts, type ArticleCheckpoint, type DraftItem } from "$stores/drafts";
	import { ndk, user } from "@kind0/ui-common";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
    import ArticleView from "$components/ArticleView.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { goto } from "$app/navigation";
	import { onMount } from "svelte";

    let draftId: string;
    let draftItem: DraftItem | undefined;
    let article: NDKArticle | undefined;
    let mounted = false;

    onMount(() => {
        mounted = true;
    });

    $: if (mounted && $user) {
        draftId = $page.params.id;
        if (draftId) {
            draftItem = $drafts.find(d => d.id === draftId);

            if (!draftItem) {
                goto("/drafts");
            } else {
                const checkpoints = JSON.parse(draftItem.checkpoints) as DraftItem["checkpoints"];
                let checkpoint = checkpoints.find(c => c.manuallySaved);
                checkpoint = checkpoints[0];

                const payload = checkpoint?.data as ArticleCheckpoint;

                article = new NDKArticle($ndk, JSON.parse(payload.article));
                article.pubkey ??= $user.pubkey;
                article.author = $user;
            }
        }
    }
</script>

<MainWrapper
    class="flex-col justify-start items-start gap-2 sm:gap-8 flex pb-6 sm:py-6"
    marginClass={`max-w-3xl`}
    mobilePadded={false}
>
    {#key draftId}
        {#if article}
            <a href="/articles/new?draft={draftId}" class="button text-lg">
                Continue editing
            </a>
            <ArticleView {article} isFullVersion={true} />
        {/if}
    {/key}
</MainWrapper>

