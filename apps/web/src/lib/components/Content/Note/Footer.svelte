<script lang="ts">
	import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
    import { NDKArticle, NDKEvent, NDKKind, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, CardsThree, Check, Lightning, Repeat } from "phosphor-svelte";
	import Tts from '$components/Actions/TTS/TTS.svelte';
	import { openModal } from "$utils/modal";
	import ShareModal from "$modals/ShareModal.svelte";
	import BookmarkFooterButton from "$components/Layout/Footers/Buttons/BookmarkFooterButton.svelte";
	import currentUser from "$stores/currentUser";
	import { createEventReply } from "$utils/event";
    import Zap from '$components/Footer/Views/Zap';
	import Comment from "$components/Footer/Views/Comment/";

    export let event: NDKEvent;
    export let mainView: 'zap' | 'tts' | "content" | undefined = undefined;
    export let collapsed = true;
    export let placeholder = "Reply";
    export let userProfile: NDKUserProfile | undefined = undefined;

    let zapped = false;

    function onZapped() {
        zapped = true;
    }

    let open: (view?: string | false) => void;

    $: if (event.pubkey === $currentUser?.pubkey) {
        placeholder = "Expand thread";
    } else if (userProfile?.displayName) {
        placeholder = `Reply to ${userProfile.displayName}`;
    }

    async function onPublish(content: string) {
        const reply = createEventReply(event);
        reply.content = content;
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
    views={[
        {...Zap, buttonProps: { zapped }, props: { event, onZapped }},
        {...Comment, props: { event, placeholder }},
    ]}
>
    <div slot="main">
        {#if mainView === 'tts'}
            <Tts {event} />
        {:else}
            <div class="grid grid-cols-3 gap-2">
                <Button variant="outline" class="footer-button flex flex-col items-center gap-2 h-auto text-lg text-foreground bg-opacity-50 p-4"
                    on:click={() => openModal(ShareModal, { event })}
                >
                    <Repeat size={40} />
                    Share
                </Button>

                <BookmarkFooterButton {event} />
            </div>
        {/if}
    </div>
</Footer.Shell>