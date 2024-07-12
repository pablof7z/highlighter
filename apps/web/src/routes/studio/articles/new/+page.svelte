<script lang="ts">
	import ArticleEditor from "$components/Forms/ArticleEditor.svelte";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Writable } from "svelte/store";

    const article = getContext("event") as Writable<NDKArticle>;
    let contentChangedSinceLastSave = 0;

    $article ??= new NDKArticle($ndk);
    $: if ($currentUser && !$article.pubkey) $article.pubkey = $currentUser.pubkey;
    
    function onArticleChange() {
        contentChangedSinceLastSave++;
    }
</script>

<ArticleEditor bind:article={$article} on:contentUpdate={onArticleChange} />