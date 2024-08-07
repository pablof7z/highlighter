<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { NDKEvent, NDKHighlight, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
    import * as Composer from "$components/Composer";
	import { get, Writable } from "svelte/store";
	import { closeModal } from "$utils/modal";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import HighlightBody from "$components/HighlightBody.svelte";

    export let event: NDKEvent;
    export let tags: NDKTag[] = [];
    export let onPublish: ((event: NDKEvent) => void) | undefined = undefined;

    let publishing = false;

    let state: Writable<Composer.ComposerState>;
</script>

<Composer.Root
    mentionEvent={event}
    {tags}
    bind:state
    let:actionButtons
    let:secondaryButtons
    on:publish={(e) => {
        onPublish?.(e);
        closeModal();
    }}
>
    <ModalShell
        title="Quote"
        class="w-full sm:max-w-2xl"
        {actionButtons}
        {secondaryButtons}
    >
        <Composer.Editor
            {state}
            placeholder="What are your thoughts?"
        />
        <Composer.Attachments {state} />

        {#if event instanceof NDKHighlight}
            <HighlightBody
                highlight={event}
                skipHighlighter={false}
                scrollIntoView={true}
                contentClass="max-h-[10vh] overflow-y-auto scrollbar-hide"
                class="p-2 rounded bg-secondary"
            />
        {:else}
            <EventWrapper
                {event}
                compact
                skipFooter
                class="bg-secondary rounded max-h-[15dvh] overflow-y-auto"
            />
        {/if}
        
    </ModalShell>
</Composer.Root>
<!-- <ModalShell
    title="Quote"
    class="w-full sm:max-w-2xl"
    actionButtons={[
        { name: "Publish" }
    ]}
>
    <Composer.Root>
        <Composer.Editor>

        </Composer.Editor>
    </Composer.Root>
    <NewPost
        kind={1}
        placeholder="What are your thoughts?"
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
                        contentClass="max-h-[10vh] overflow-y-auto scrollbar-hide"
                        class="p-2 rounded bg-secondary"
                    />
                {:else}
                    <EventWrapper
                        {event}
                        class="p-2 rounded bg-secondary"
                        skipFooter={true}
                        showReply={false}
                        compact
                        expandReplies={false}
                        expandThread{false}
                    />
                {/if}
            </div>
        </div>
    </NewPost>
</ModalShell> -->