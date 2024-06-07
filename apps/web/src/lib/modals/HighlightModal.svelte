<script lang="ts">
	import NewPost from "$components/Creator/NewPost.svelte";
	import Highlight from "$components/Highlight.svelte";
    import HighlightIcon from "$icons/HighlightIcon.svelte";
	import HighlightBody from "$components/HighlightBody.svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import ModalShell from "$components/ModalShell.svelte";
	import currentUser from "$stores/currentUser";
	import { closeModal } from "$utils/modal";
    import { NDKEvent, NDKHighlight, NDKKind } from "@nostr-dev-kit/ndk";
	import { ChatCircle, CardsThree, Lightning, Recycle, Repeat } from "phosphor-svelte";

    export let highlight: NDKEvent;
    export let showReply: boolean = false;
    export let replyKind: number = NDKKind.Text;
    export let skipArticle = true;
</script>

<ModalShell
    class="max-w-3xl"
    title="Highlight"
>
    {#key highlight.content}
        <HighlightBody
            highlight={NDKHighlight.from(highlight)}
            skipHighlighter={true}
            scrollable={true}
            {skipArticle}
            scrollIntoView={true}
            class="p-4max-h-[20vh] overflow-auto scrollbar-hide"
        />

        <HorizontalOptionsList options={[
            { name: "Comments", href: `/comments`, icon: ChatCircle, badge: "1" },
            { name: "Shares", href: `/highlights`, icon: Repeat },
            { name: "Curations", href: `/curations`, icon: CardsThree },
            { name: "Zaps", icon: Lightning },
        ]} value="Comments" class="my-4" />
        
        <!-- <NewPost
            kind={replyKind}
            bind:showReply
            autofocus={true}
            placeholder="What are your thoughts?"
            collapsed={false}
            on:publish={() => {
                showReply = false;
                highlight.publish();
            }}
            on:cancel={() => {
                closeModal();
                window.history.back();
            }}
        /> -->
    {/key}
</ModalShell>