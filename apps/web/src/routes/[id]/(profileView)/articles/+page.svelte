<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext } from 'svelte';
	import { Readable } from 'svelte/store';
    import { NDKArticle } from "@nostr-dev-kit/ndk";

    const userArticles = getContext('userArticles') as Readable<NDKArticle[]>;
</script>

<div class="responsive-padding">
    <Feed.Articles
        store={userArticles}
        skipAuthor
    />
</div>