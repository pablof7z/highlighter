<script lang="ts">
	import { goto } from "$app/navigation";
	import ContentSidebar from "$components/Creator/ContentSidebar.svelte";
	import CommentIcon from "$icons/CommentIcon.svelte";
	import LikeIcon from "$icons/LikeIcon.svelte";
	import RepostIcon from "$icons/RepostIcon.svelte";
	import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { userCreatorSubscriptionPlans } from "$stores/session";
	import { getUserSupportPlansStore, startUserView, userSubscription } from "$stores/user-view";
	import { ndk, user } from "@kind0/ui-common";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Lock } from "phosphor-svelte";
	import { onDestroy, onMount } from "svelte";
	import { openModal } from "svelte-modals";

    export let article: NDKArticle;
    const author = article.author;

    onMount(() => {
        startUserView(author);
    });

    onDestroy(() => {
        userSubscription?.unref();
    });

    const tiers = getUserSupportPlansStore();

    // Check if this suer has access to the full article and if they do, redirect them to the full article
    const fullTiers = article.getMatchingTags("tier").map(t => t[1]);

    $: if (fullTiers.includes($userCreatorSubscriptionPlans.get(article.pubkey))) {
        const parts = article.tagValue("full")?.split(/:/) as string[];
        const dTag = parts[2] || parts[0];
        goto(`/${author.npub}/${dTag}`);
    }

    const isTeaser = !!article.tagValue("full");

    let content = article.content;

    function openSupportModal() {
        openModal(BecomeSupporterModal, { user: author, tiers });
    }
</script>

{#if article.image}
    <img class="w-full rounded-[20px] max-h-[50vh] object-cover object-top" src={article.image} />
{/if}
<div class="flex-col justify-start items-center gap-10 flex w-full">
    <div class="self-stretch justify-center items-start gap-8 inline-flex">
        <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
            <div class="self-stretch flex-col justify-center items-start gap-6 flex">
                <div class="self-stretch flex-col justify-start items-start gap-6 flex">
                    <div class="self-stretch text-white text-2xl font-medium">
                        {article.title}
                    </div>
                    <div class="flex-col justify-start items-start gap-4 flex w-full">
                        <div class="flex flex-row items-center gap-12 w-full">
                            <div class="justify-start items-start gap-3 inline-flex">
                                <div class="w-7 h-7 relative">
                                    <LikeIcon class="w-7 h-7" />
                                </div>
                                <div class="w-7 h-7 relative">
                                    <CommentIcon class="w-7 h-7" />
                                </div>
                                <div class="w-7 h-7 relative">
                                    <RepostIcon class="w-7 h-7" />
                                </div>
                            </div>

                            {#if article.pubkey === $user.pubkey}
                                <a href="/articles/{article.tagValue("d")}/edit" class="button">Edit</a>
                            {/if}
                        </div>
                        <div class="w-[600px] text-white text-opacity-60 text-sm font-normal leading-[21px]">32 responses  108 boosts</div>
                    </div>
                </div>
                <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-7 relative w-full">
                    <EventContent ndk={$ndk} event={article} {content} />

                    {#if isTeaser}
                        <div class="absolute bottom-0 right-0 bg-gradient-to-t from-black to-transparent via-black/70 w-full h-2/3 flex flex-col items-center justify-center">
                            <button
                                class="button flex flex-row items-center gap-2 px-6 py-3 z-50 absolute whitespace-nowrap"
                                on:click={openSupportModal}
                            >
                                <Lock class="w-6 h-6" />
                                Become a fan to unlock
                            </button>
                        </div>
                    {/if}
                </div>
            </div>
        </div>

        <ContentSidebar event={article} />
    </div>
</div>