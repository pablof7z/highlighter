<script lang="ts">
	import ContentSidebar from "$components/Creator/ContentSidebar.svelte";
	import VideoPlayer from "$components/Events/VideoPlayer.svelte";
	import EventActionButtons from "$components/buttons/EventActionButtons.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk, user } from "@kind0/ui-common";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Lock } from "phosphor-svelte";
	import { onDestroy, onMount } from "svelte";

    export let article: NDKArticle;
    const author = article.author;

    onMount(() => {
        startUserView(author);
    });

    onDestroy(() => {
        userSubscription?.unref();
    });

    const isTeaser = !!article.tagValue("full");

    let content = article.content;

    const mTag = article.getMatchingTags("m")[0]!;
    const videoUrl = mTag[2];
    let editUrl = `/videos/${article.tagValue("d")}/edit`;

    const requiredTier = requiredTiersFor(article)[0];
</script>

{#if videoUrl}
    <div class="w-full min-h-[50vh] max-h-[60vh] flex flex-col items-stretch justify-stretch">
        <VideoPlayer url={videoUrl} />
    </div>
{:else if article.image && isTeaser}
    <div class="relative w-full max-h-[80vh]">
        <img class="w-full rounded-[20px] max-h-[80vh] object-cover object-top" src={article.image} />
        <div class="absolute top-0 left-0 w-full h-full bg-black/50 flex flex-col items-center justify-center">
            <UpgradeButton event={article} />
        </div>
    </div>
{/if}

<div class="flex-col justify-start items-center gap-10 flex w-full">
    <div class="self-stretch justify-center items-start gap-8 inline-flex">
        <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
            <div class="self-stretch flex-col justify-center items-start gap-6 flex">
                <div class="self-stretch flex-col justify-start items-start gap-6 flex">
                    <div class="self-stretch text-white text-2xl font-medium">
                        <div class="flex flex-row w-full justify-between items-center">
                            <div>{article.title}</div>

                            {#if isTeaser}
                                <UpgradeButton class="!bg-transparent text-white text-xs" event={article} />
                            {/if}
                        </div>
                    </div>
                    <div class="flex-col justify-start items-start gap-4 flex w-full">
                        <div class="flex flex-row items-center gap-12 w-full">
                            <EventActionButtons
                                event={article}
                                on:comment
                            />

                            {#if article.pubkey === $user?.pubkey}
                                <a href={editUrl} class="button">Edit</a>
                            {/if}
                        </div>
                        <div class="w-[600px] text-white text-opacity-60 text-sm font-normal leading-[21px]">32 responses  108 boosts</div>
                    </div>
                </div>
                <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-7 w-full">
                    <EventContent ndk={$ndk} event={article} {content} />
                </div>
            </div>
        </div>
    </div>
</div>