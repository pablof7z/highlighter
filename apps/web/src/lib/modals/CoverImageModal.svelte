<script lang="ts">
	import ArticleCover from "$components/Editor/ArticleCover.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from "$utils/modal";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { NavigationOption } from "../../app";

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

    const actionButtons: NavigationOption[] = [
        { name: "No image", fn: noImage, buttonProps: { variant: 'secondary' } },
        { name: "Save", fn: save, buttonProps: { variant: 'default'} },
    ]
</script>

<ModalShell
    class="max-w-3xl w-full"
    title="Cover Image"
    {actionButtons}
>
    <ArticleCover bind:article={article} />
</ModalShell>