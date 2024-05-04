<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import { NDKEvent, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
    import { closeModal } from "$utils/modal";
	import { ndk } from "@kind0/ui-common";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";

    export let replyTo: NDKEvent | undefined = undefined;
    export let tags: NDKTag[] = [];
    export let placeholder = "What is happening?!";

    if (replyTo) {
        const e = new NDKEvent($ndk);
        e.tag(replyTo, "reply");
        tags = [...tags, ...e.tags]
    }
    
    let publishing = false;
</script>

<ModalShell
    color="glassy" class="w-full sm:max-w-2xl !p-2 max-sm:h-full {publishing ? "!bg-transparent" : ""}"
>
    {#if publishing}
        <div class="loading loading-lg loading-dots"></div>
    {/if}

    {#if replyTo}
        <EventWrapper
            ndk={$ndk}
            event={replyTo}
            class="text-white text-xs"
            skipFooter={true}
            skipReply={true}
            skipZaps={true}
            skipSwipe={true}
            expandReplies={false}
            exppandThread={false}
        />
    {/if}

    <div class="w-full flex flex-col max-sm:min-h-[85dvh]">
        <NewPost
            kind={NDKKind.Text}
            {placeholder}
            editorClass="text-white min-h-[7rem] max-sm:min-h-[70dvh] h-full grow"
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