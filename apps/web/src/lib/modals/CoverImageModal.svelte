<script lang="ts">
	import ArticleCover from "$components/Editor/ArticleCover.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import Button from "$components/ui/button/button.svelte";
	import { closeModal } from "$utils/modal";
    import { NDKArticle } from "@nostr-dev-kit/ndk";

    export let article: NDKArticle;
    export let onSave: ((article: NDKArticle) => void) | undefined = undefined;

    function save() {
        if (onSave)
            onSave(article);
        closeModal();
    }

    function noImage() {
        article.image = undefined;
        save();
    }
</script>

<ModalShell class="max-w-3xl w-full" title="Cover Image">
    <ArticleCover bind:article={article} />

    <svelte:fragment slot="footer">
        <Button variant="secondary" on:click={noImage}>
            No image
        </Button>
        <Button on:click={save}>
            Save
        </Button>
    </svelte:fragment>
</ModalShell>