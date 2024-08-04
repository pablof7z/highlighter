<script lang="ts">
    import ArticleEditor from "$components/Studio/Editor/Article.svelte";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Writable } from "svelte/store";
    import { Types as StudioItemTypes } from "$components/Studio";

    const type = getContext("type") as Writable<StudioItemTypes>;
    const article = getContext("event") as Writable<NDKArticle>;

    let contentChangedSinceLastSave = 0;

    $type = StudioItemTypes.Article;

    $article ??= new NDKArticle($ndk);
    $: if ($currentUser && !$article.pubkey) $article.pubkey = $currentUser.pubkey;
    
    function onArticleChange() {
        contentChangedSinceLastSave++;
    }
</script>

<ArticleEditor bind:article={$article} on:contentUpdate={onArticleChange} />