<script lang="ts">
	import { OpenFn } from "$components/Footer";
	import HighlightBody from "$components/HighlightBody.svelte";
	import { Button } from "$components/ui/button";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import NewPostModal from "$modals/NewPostModal.svelte";
	import QuoteModal from "$modals/QuoteModal.svelte";
	import ShareModal from "$modals/ShareModal.svelte";
	import currentUser from "$stores/currentUser";
    import { layout } from "$stores/layout";
	import { openModal } from "$utils/modal";
	import NDK, { NDKArticle, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { Repeat, Quotes, ChatCircle, X } from "phosphor-svelte";

    export let open: OpenFn;
    export let article: NDKArticle;
    export let hideCollapsedView: boolean;
    const highlight: NDKHighlight = $layout.footer?.props?.highlight;

    hideCollapsedView = true;

    if (!highlight) {
        console.warn('No highlight provided to HighlightViewer');
        open(false);
    }

    let mode: 'comment' | 'share' | 'quote' | undefined;

    function setMode(mode: 'comment' | 'share' | 'quote') {
        return () => {
            if (mode === 'comment') {
                openModal(NewPostModal, {
                    replyTo: highlight,
                    placeholder: 'Reply to this highlight',
                })
            } else if (mode === 'share') {
                openModal(ShareModal, { event: highlight });
            } else if (mode === 'quote') {
                openModal(QuoteModal, { event: highlight });
            }
        }
    }
</script>

{#if highlight}
    <div class="flex flex-col gap-6">
        <div class="flex flex-row justify-between">
            <div class="flex flex-row gap-2">
                <!-- <Button variant="accent" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={highlight}>
                    <HighlightIcon class="w-6 h-6" />
                    <span>Highlight</span>
                </Button> -->

                <Button variant="secondary" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={setMode('share')}>
                    <Repeat class="w-6 h-6" weight="fill" />
                    <span class="max-sm:hidden">Repost</span>
                </Button>

                <Button variant="secondary" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={setMode('quote')}>
                    <Quotes class="w-6 h-6" />
                    <span class="max-sm:hidden">Quote</span>
                </Button>
                <Button variant="secondary" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={setMode('comment')}>
                    <ChatCircle class="w-6 h-6" weight="fill" />
                    <span class="max-sm:hidden">Comment</span>
                </Button>
            </div>

            <Button size="icon" variant="secondary" class="flex flex-row gap-2 items-center" on:click={() => open(false)}>
                <X class="w-6 h-6" />
            </Button>
        </div>
    </div>

    <div class="bg-secondary p-3 rounded border">
        <HighlightBody
            {highlight}
            skipArticle
            skipHighlighter={highlight.pubkey === $currentUser?.pubkey}
        />

        {#if highlight.pubkey !== $currentUser?.pubkey}

        {/if}
    </div>
{/if}