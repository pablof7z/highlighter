<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
    import HighlightBody from "$components/HighlightBody.svelte";
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
	import { NDKEvent, NDKHighlight, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
	import { closeModal } from '$utils/modal';
	import EventWrapper from "$components/Feed/EventWrapper.svelte";

    export let event: NDKEvent;
    export let tags: NDKTag[] = [];
    export let onPublish: ((event: NDKEvent) => void) | undefined = undefined;

    let publishing = false;
</script>

<ModalShell color="glassy" class="w-full sm:max-w-2xl !p-2 {publishing ? "!bg-transparent" : ""}">
    {#if publishing}
        <div class="loading loading-lg loading-dots"></div>
    {/if}

    <NewPost
        kind={1}
        placeholder="What are your thoughts?"
        editorClass="text-white min-h-[7rem]"
        collapsed={false}
        autofocus={true}
        extraTags={tags}
        bind:publishing
        on:publish={() => {
            closeModal();
            onPublish?.(event);
        }}
        on:cancel={closeModal}
        mentionEvent={event}
    >
        <div slot="afterContent">
            <div class="w-full max-sm:hidden">
                {#if event.kind === NDKKind.Highlight}
                    <HighlightBody
                        highlight={NDKHighlight.from(event)}
                        skipHighlighter={false}
                        scrollIntoView={true}
                        contentClass="max-h-[10vh] overflow-y-auto"
                        class="py-4 bg-base-300"
                    />
                {:else}
                    <EventWrapper
                        {event}
                        class="py-4 bg-base-300"
                        skipFooter={true}
                        showReply={false}
                        expandReplies={false}
                        expandThread{false}
                    />
                {/if}
            </div>
        </div>

        <!-- <div slot="buttonsBar" class="grow">
            <button class="text-sm">
                Configure zap-splits
            </button>
        </div> -->
    </NewPost>
</ModalShell>