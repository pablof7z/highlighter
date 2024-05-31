<script lang="ts">
	import ArticleCover from "$components/Editor/ArticleCover.svelte";
    import ModalShell from "$components/ModalShell.svelte";
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

<ModalShell class="max-w-3xl w-full" color="glassy" title="Cover Image">
    <ArticleCover bind:article={article} />

    <svelte:fragment slot="footer">
        <button class="hover:text-white" on:click={noImage}>
            No image
        </button>
        <button class="button px-6" on:click={save}>
            Save
        </button>
    </svelte:fragment>
</ModalShell>