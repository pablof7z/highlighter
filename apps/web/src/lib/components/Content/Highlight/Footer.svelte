<script lang="ts">
	import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
    import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { Repeat } from "phosphor-svelte";
	import { openModal } from "$utils/modal";
	import ShareModal from "$modals/ShareModal.svelte";
	import BookmarkFooterButton from "$components/Layout/Footers/Buttons/BookmarkFooterButton.svelte";
	import { createEventReply } from "$utils/event";
    import Zap from '$components/Footer/Views/Zap';

    export let event: NDKEvent;
    export let mainView: 'zap' | "content" | undefined = undefined;
    export let collapsed = true;
    export let placeholder = "Reply";

    let zapped = false;

    function onZapped() {
        zapped = true;
    }

    let open: (view?: string | false) => void;

    placeholder = "Comment on this highlight";

    async function onPublish(content: string) {
        const reply = createEventReply(event);
        reply.content = content;
        reply.tags.push(["k", NDKKind.Highlight.toString()]);
        await reply.sign();
        reply.publish();
    }
</script>

<Footer.Shell
    bind:collapsed
    bind:mainView
    bind:open
    {onPublish}
    {placeholder}
    buttons={[
        {...Zap, buttonProps: { zapped }, props: { event, onZapped }}
    ]}
>
    <div slot="main">
        <div class="grid grid-cols-3 gap-2">
            <Button variant="outline" class="footer-button flex flex-col items-center gap-2 h-auto text-lg text-foreground bg-opacity-50 p-4"
                on:click={() => openModal(ShareModal, { event })}
            >
                <Repeat size={40} />
                Share
            </Button>

            <BookmarkFooterButton {event} />
        </div>
    </div>
</Footer.Shell>