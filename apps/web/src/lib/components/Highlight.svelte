<script lang="ts">
    import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKHighlight, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import HighlightBody from "./HighlightBody.svelte";
    import * as Card from '$components/ui/card';
	import Zap from "./Footer/Buttons/Zap.svelte";
	import Comments from "./Footer/Buttons/Comments.svelte";
	import Bookmark from "./Footer/Buttons/Bookmark.svelte";
	import Share from "./Footer/Buttons/Share.svelte";
	import Button from "./ui/button/button.svelte";
	import AvatarWithName from "./User/AvatarWithName.svelte";
	import { createEventDispatcher } from "svelte";

    export let highlight: NDKHighlight;
    export let highlightedArticle: NDKArticle | NDKEvent | string | undefined = undefined;
    export let skipArticle: boolean = false;
    export let expandReplies = false;
    export let showReply = false;
    export let scrollIntoView = false;
    export let compact: boolean | undefined = undefined;
    export let skipFooter = false;
    export let disableSwipe = false;

    const dispatch = createEventDispatcher();
    
    function close() {
        dispatch('close');
    }
</script>

<Card.Root>
    <Card.Header>
        <AvatarWithName user={highlight.author} avatarSize="tiny" class="text-xs text-opacity-60" />
    </Card.Header>
    <Card.Content>
        <HighlightBody
            {highlight}
            {highlightedArticle}
            {skipArticle}
            {scrollIntoView}
            contentClass="overflow-clip sm:overflow-auto scrollbar-hide"
        />
    </Card.Content>
    <Card.Footer class="w-full">
        <div class="flex flex-row justify-between w-fit gap-4 items-end grow">
            &nbsp;
            <!-- <Button on:click={close}>
                Close
            </Button> -->
            <div class="flex flex-row justify-between w-fit gap-4 items-end">
                <Zap event={highlight} />
                <Comments event={highlight} />
                <Share event={highlight} />
                <Bookmark event={highlight} />
            </div>
        </div>
    </Card.Footer>
</Card.Root>