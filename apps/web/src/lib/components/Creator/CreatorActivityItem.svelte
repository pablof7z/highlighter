<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import UserProfile from "$components/User/UserProfile.svelte";
	import EventActionButtons from "$components/buttons/EventActionButtons.svelte";
	import { debugMode } from "$stores/session";
	import { urlSuffixFromEvent } from "$utils/url";
	import { Avatar, Name, ndk } from "@kind0/ui-common";
	import { NDKKind, NDKArticle, type NDKEvent, type NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;
    export let creatorUrl: string;

    async function getRootEvent(e: NDKEvent): Promise<NDKEvent | null> {
        const rootTag = getRootEventTag(e);
        if (!rootTag) return null;

        return await $ndk.fetchEvent(rootTag[1]);
    }

    function getRootEventTag(e: NDKEvent): NDKTag | undefined {
        const aTags = e.getMatchingTags("a");
        const eTags = e.getMatchingTags("e");

        // try to find one with a root marker ("root" as the .[3] position)
        for (const tag of aTags) { if (tag[3] === "root") return tag; }
        for (const tag of eTags) { if (tag[3] === "root") return tag; }

        // return the first a tag
        if (aTags.length > 0) return aTags[0];

        // return the first e tag
        if (eTags.length > 0) return eTags[0];
    }

    let rootEvent: NDKEvent | NDKArticle | NDKVideo | null;

    getRootEvent(event).then((e) => {
        if (!e) return;

        switch (e.kind) {
            case NDKKind.Article: rootEvent = NDKArticle.from(e); break;
            case NDKKind.HorizontalVideo: rootEvent = NDKVideo.from(e); break;
            default: rootEvent = e;
        }

        itemUrl = `${creatorUrl}/${urlSuffixFromEvent(rootEvent)}`;
    })

    let itemUrl: string;
</script>

<UserProfile user={event.author} let:userProfile let:fetching>
    <div class="pb-3 flex-col justify-start items-start gap-2 inline-flex">

        {#if rootEvent}
            <div class="text-sm font-normal">
                <span class="text-white text-opacity-60">Replied to </span>
                <a href={itemUrl} class="text-white text-opacity-80 leading-[17px]">
                    {#if rootEvent instanceof NDKArticle}
                        {rootEvent.title}
                    {:else}
                        {rootEvent.content.substring(0, 20)}
                    {/if}
                </a>
            </div>
        {/if}

        <div class="self-stretch justify-start items-center inline-flex">
            <div class="justify-start items-center gap-4 flex">
                <div class="justify-center items-center gap-3 inline-flex">
                    <Avatar {userProfile} {fetching} class="w-8 h-8" />
                    <div class="text-white text-[15px] font-semibold leading-snug">
                        <Name {userProfile} {fetching} />
                    </div>
                </div>
            </div>
        </div>
        <div class="self-stretch text-white font-normal prose">
            <EventContent ndk={$ndk} {event} />
        </div>
        <div class="flex w-full flex-row justify-end">
            <EventActionButtons {event} />
        </div>
    </div>
</UserProfile>

{#if $debugMode}
    <pre>{JSON.stringify(event.rawEvent(), null, 2)}</pre>
{/if}