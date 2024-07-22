<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { eventToSpecificKind } from "$utils/event";
	import { ndk } from "$stores/ndk.js";
    import { NDKArticle, NDKEvent, NDKList, NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let tag: NDKTag | undefined = undefined;
    export let id: string | undefined = undefined;
    export let fetched: NDKEvent | undefined = undefined;

    let article: NDKArticle | undefined;
    let video: NDKVideo | undefined;
    let articleList: NDKList | undefined;

    if (tag) $ndk.fetchEventFromTag(tag, event).then(process);
    if (id) $ndk.fetchEvent(id, {subId:'Loadevent'}).then(process);
    
    function process(e: NDKEvent | null | undefined) {
        if (e) {
            const res = eventToSpecificKind(e);
            article = res.article;
            video = res.video;
            articleList = res.articleList;
            fetched = e;
        }
    }

</script>

{#if fetched}
    <UserProfile user={fetched.author} let:authorUrl let:userProfile let:fetching>
        <slot
            {article}
            {video}
            {articleList}
            event={fetched}
            {authorUrl}
            {userProfile}
            {fetching}
        />
    </UserProfile>
{:else}
{/if}