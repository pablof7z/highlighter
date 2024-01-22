<script lang="ts">
    import ArticleView from "$components/ArticleView.svelte";
	import { page } from "$app/stores";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { goto } from "$app/navigation";

    let id: string;

    $: id = $page.params.id;

    let event: NDKEvent | null;

    $: if (id) {
        $ndk.fetchEvent(id).then(e => {
            event = e;

            if (e && e.kind === NDKKind.Article) {
                const author = e.author;
                goto(`/${author.npub}/${e.dTag}`);
            }
        });
    }
</script>

<LoadingScreen ready={!!event}>
    <MainWrapper>
        <h1 class="text-2xl font-bold mb-4">Article</h1>
        {#if event}
            <ArticleView article={NDKArticle.from(event)} isFullVersion={true} />
        {/if}
    </MainWrapper>
</LoadingScreen>