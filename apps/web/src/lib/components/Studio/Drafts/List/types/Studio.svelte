<script lang="ts">
	import * as Studio from "$components/Studio";
	import {DraftItem} from "$stores/drafts"
	import { toast } from "svelte-sonner";
	import { getStateFromDraft } from "$components/Studio/draft";
    import * as Feed from "$components/Feed";

    export let item: DraftItem;
    let state: Studio.State<Studio.Type> | undefined;

    try {
        state = getStateFromDraft(item);
    } catch (e) {
        toast.success("Draft is not supported", { description: e.message });
    }

    let href = `/studio/drafts/${item.id}`;

    console.log('state.article', state?.article?.content)
</script>

{#if state?.type === "article"}
    <Feed.Items.Article href="/studio/article?draft={item.id}" article={state.article} />
{:else}
    <pre>{JSON.stringify(state, null, 2)}</pre>
{/if}
