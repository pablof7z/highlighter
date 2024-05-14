<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { Avatar, Name, RelativeTime, ndk } from "@kind0/ui-common";
    import { NDKArticle, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;

    const articleId = event.tagValue("a");

    let article: NDKArticle;

    if (articleId) {
        $ndk.fetchEvent(articleId).then(e => {
            if (e) article = NDKArticle.from(e);
        });
    }
</script>

<UserProfile user={event.author} let:userProfile let:fetching>
<div class="flex-col justify-start items-start gap-4 inline-flex">
    <div class="self-stretch justify-start items-center inline-flex">
        <div class="grow shrink basis-0 justify-start items-center gap-4 flex">
            <Avatar {userProfile} {fetching} size="medium" />
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-1 inline-flex">
                <div class="self-stretch justify-between items-center inline-flex">
                    <div class="text-white font-semibold leading-5">
                        <Name {userProfile} {fetching} />
                    </div>
                </div>
                <div class="text-white text-opacity-60 font-normal leading-5">
                    <RelativeTime {event} />
                </div>
            </div>
        </div>
    </div>

    {#if article}
        <div class="!text-white font-semibold leading-5">
            Shared a highlight of {article.title}
        </div>
    {:else}
        <div class="!text-white font-semibold leading-5">
            Shared a highlight
        </div>
    {/if}

    <!-- <ArticleCard {article} skipSummary={true} imageClass="w-1/12" /> -->
    {#if event.content.length > 0}
        <EventContent ndk={$ndk} {event} showEntire={true} maxLength={9999} class="text-sm !font-light prose" />
    {/if}
</div>
</UserProfile>