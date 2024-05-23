<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { eventToSpecificKind } from "$utils/event";
	import { ndk } from "@kind0/ui-common";
    import { NDKArticle, NDKEvent, NDKList, NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";

    export let tag: NDKTag | undefined = undefined;
    export let id: string | undefined = undefined;

    let event: NDKEvent | null;
    let article: NDKArticle | undefined;
    let video: NDKVideo | undefined;
    let articleList: NDKList | undefined;

    if (tag) $ndk.fetchEventFromTag(tag).then(process);
    if (id) $ndk.fetchEvent(id).then(process);
    
    function process(e: NDKEvent | null) {
        event = e;
        if (e) {
            const res = eventToSpecificKind(e);
            article = res.article;
            video = res.video;
            articleList = res.articleList;
        }
    }

</script>

{#if event}
    <UserProfile user={event.author} let:authorUrl let:userProfile let:fetching>
        <slot
            {article}
            {video}
            {articleList}
            {event}
            {authorUrl}
            {userProfile}
            {fetching}
        />
    </UserProfile>
    {:else}
    here
{/if}