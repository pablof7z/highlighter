<script lang="ts">
	import { Button } from "$components/ui/button";
	import NewPostModal from "$modals/NewPostModal.svelte";
	import QuoteModal from "$modals/QuoteModal.svelte";
	import ShareModal from "$modals/ShareModal.svelte";
	import { layout } from "$stores/layout";
	import { openModal } from "$utils/modal";
	import { NDKHighlight } from "@nostr-dev-kit/ndk";
	import { Repeat, Quotes, ChatCircle } from "phosphor-svelte";

    const highlight: NDKHighlight = $layout.footer?.props?.highlight;

    function comment() {
        openModal(NewPostModal, {
            replyTo: highlight,
            placeholder: 'Reply to this highlight',
        })
    };
    function share() { openModal(ShareModal, { event: highlight }); }
    function quote() { openModal(QuoteModal, { event: highlight }); }
</script>

<div class="flex flex-row gap-2">
    <Button variant="secondary" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={share}>
        <Repeat class="w-6 h-6" weight="fill" />
        <span class="max-sm:hidden">Repost</span>
    </Button>

    <Button variant="secondary" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={quote}>
        <Quotes class="w-6 h-6" />
        <span class="max-sm:hidden">Quote</span>
    </Button>
    <Button variant="secondary" class="flex flex-row gap-2 w-fit h-fit items-center" on:click={comment}>
        <ChatCircle class="w-6 h-6" weight="fill" />
        <span class="max-sm:hidden">Comment</span>
    </Button>
</div>