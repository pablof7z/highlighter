<script lang="ts">
    import * as Studio from '$components/Studio';
	import currentUser from '$stores/currentUser';
	import { Writable } from 'svelte/store';
    import * as Article from "$components/Content/Article";
    import * as Content from "$components/Content";
    
    export let state: Writable<Studio.State<Studio.Type.Article>>;
    const article = $state.article;

    if (!article.pubkey && $currentUser) article.pubkey = $currentUser.pubkey;
</script>

<Article.Header
    article={$state.article}
    isPreview
>

</Article.Header>

<Content.Body event={$state.article} isPreview>
</Content.Body>