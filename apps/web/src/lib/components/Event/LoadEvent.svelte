<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { eventToSpecificKind } from "$utils/event";
	import { ndk } from "$stores/ndk.js";
    import { NDKArticle, NDKEvent, NDKList, NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let tag: NDKTag | undefined = undefined;
    export let id: string | undefined = undefined;

    let e: NDKEvent | null;
    let article: NDKArticle | undefined;
    let video: NDKVideo | undefined;
    let articleList: NDKList | undefined;

    if (tag) $ndk.fetchEventFromTag(tag, event).then(process);
    if (id) $ndk.fetchEvent(id, {subId:'Loadevent'}).then(process);
    
    function process(e: NDKEvent | null) {
        e = e;
        if (e) {
            const res = eventToSpecificKind(e);
            article = res.article;
            video = res.video;
            articleList = res.articleList;
        }
    }

</script>

{#if e}
    <UserProfile user={e.author} let:authorUrl let:userProfile let:fetching>
        <slot
            {article}
            {video}
            {articleList}
            event={e}
            {authorUrl}
            {userProfile}
            {fetching}
        />
    </UserProfile>
{:else}
{/if}