<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import { NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
    import { closeModal } from "$utils/modal";

    export let tags: NDKTag[] = [];
    export let placeholder = "What are your thoughts?";

    let publishing = false;
</script>

<ModalShell
    color="glassy" class="w-full sm:max-w-2xl !p-2 {publishing ? "!bg-transparent" : ""}"
>
    {#if publishing}
        <div class="loading loading-lg loading-dots"></div>
    {/if}

    <div class="w-full flex flex-col">
        <NewPost
            kind={NDKKind.Text}
            {placeholder}
            editorClass="text-white min-h-[7rem]"
            skipAvatar={true}
            collapsed={false}
            autofocus={false}
            extraTags={tags}
            bind:publishing
            on:publish={() => {
                closeModal();
            }}
            on:cancel={closeModal}
        />
    </div>
</ModalShell>