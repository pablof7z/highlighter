<script lang="ts">
	import ArticleEditPage from "$components/Editor/ArticleEditPage.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle } from "@nostr-dev-kit/ndk";

    let article = new NDKArticle($ndk);
	let preview = new NDKArticle($ndk);
</script>


<svelte:head>
	<title>New article</title>
</svelte:head>

<ArticleEditPage {article} {preview} />
