<script lang="ts">
	import ArticleEditPage from "$components/Forms/ArticleEditPage.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle } from "@nostr-dev-kit/ndk";

    let article = new NDKArticle($ndk);
</script>

<ArticleEditPage {article} />