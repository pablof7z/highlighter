<script lang="ts">
	import HighlightIcon from '../icons/HighlightIcon.svelte';
	import { goto } from "$app/navigation";
	import EventActionButtons from "$components/buttons/EventActionButtons.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { debugMode, userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription, userTiers } from "$stores/user-view";
	import { ndk, pageDrawerToggle, rightSidebar, user, HighlightWrapper, Avatar, Name } from "@kind0/ui-common";
	import { NDKEvent, type NDKArticle, NDKKind, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { onDestroy, onMount } from "svelte";
	import { addReadReceipt } from '$utils/read-receipts';
	import { MarkerCircle, Quotes, Receipt, X } from 'phosphor-svelte';
    import { getParagraph, getText } from "get-selection-more";
	import { getDefaultRelaySet } from '$utils/ndk';
	import UserProfile from '$components/User/UserProfile.svelte';

    export let article: NDKArticle;
    const author = article.author;
    export let editUrl: string | undefined = undefined;
    export let isFullVersion: boolean;

    onMount(() => {
        startUserView(author);
        addReadReceipt(article);
    });

    onDestroy(() => {
        userSubscription?.unref();
    });

    // Check if this user has access to the full article and if they do, redirect them to the full article
    const fullTiers = article.getMatchingTags("tier").map(t => t[1]);

    $: if (fullTiers.includes($userActiveSubscriptions.get(article.pubkey))) {
        const parts = article.tagValue("full")?.split(/:/) as string[];
        const dTag = parts[2] || parts[0];
        goto(`/${author.npub}/${dTag}`);
    }

    let content = article.content;

    editUrl ??= `/articles/${article.tagValue("d")}/edit`;

    onMount(() => {
        document.addEventListener('click', function(event) {
            // if the target is not the container nor a descendant of the container
            if (!el?.contains(event.target as Node)) {
                if (el?.classList.contains('opacity-0')) return;
                el?.classList.add('opacity-0');
            }
        });
        document.addEventListener('mouseup', function(event) {
            let selection = window.getSelection();
            if (selection.toString().length > 0) {
                let range = selection.getRangeAt(0);
                let rect = range.getBoundingClientRect();

                // Create the floating element
                el.style.top = (rect.top + window.scrollY - 50) + 'px';
                el.style.left = (rect.right + window.scrollX) + 'px';
                // remove opacity-0 class
                setTimeout(() => {
                    el?.classList.remove('opacity-0');
                }, 10)
                // setTimeout(() => {
                //     el?.appendChild(floatElement);
                // }, 100)
            }
        });


    })

    let el: HTMLDivElement;

    async function createHighlight() {
        const content = getText();

        if (!content) return;

        const groupId = article.tagValue("h");
        const event = new NDKEvent($ndk, {
            kind: NDKKind.Highlight,
            content,
            tags: [
                [ "context", getParagraph() ]
            ]
        } as NostrEvent);

        // add h tag if it exists
        if (groupId) event.tags.push(["h", groupId]);

        event.tag(article);
        await event.sign();
        await event.publish()
    }
</script>

<svelte:head>
    <title>{article.title}</title>
</svelte:head>

<div bind:this={el} class="float-element z-50 absolute opacity-0 transition-all duration-300 flex flex-col gap-1">
    <button class="
        button px-4 py-3
        transition-all duration-300
    " on:click={createHighlight}>
        <HighlightIcon class="w-6 h-6" />
        Highlight
    </button>
</div>

<div class="w-full">
    {#if article.image}
        <div class="w-full max-h-[50vh] relative overflow-hidden">
            <img class="w-full relative sm:rounded-xl object-cover object-top h-full" src={article.image} />
            <div class="absolute bottom-0 w-full h-2/5 bg-gradient-to-b from-transparent to-black"></div>
        </div>
    {/if}

    <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4">
        <div class="self-stretch justify-center items-start gap-8 inline-flex">
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
                <div class="self-stretch flex-col justify-center items-start flex">
                    <div class="self-stretch flex-col justify-start items-start gap-1 flex">
                        <div class="self-stretch text-white text-2xl font-medium">
                            {article.title}
                        </div>
                        <div class="flex-row justify-between items-center gap-4 flex w-full">
                            <UserProfile user={article.author} let:userProfile let:fetching let:authorUrl>
                                <a href={authorUrl} class="flex flex-row items-center gap-4 p-4 h-fit flex-grow">
                                    <Avatar {userProfile} {fetching} size="medium" />

                                    <Name  {userProfile} {fetching} class="whitespace-nowrap truncate" />
                                </a>
                            </UserProfile>

                            <div class="flex flex-row items-center gap-12">
                                <EventActionButtons
                                    event={article}
                                    on:comment
                                />

                                {#if article.pubkey === $user?.pubkey}
                                    <a href={editUrl} class="button">Edit</a>
                                {/if}
                            </div>
                        </div>
                    </div>
                    <article class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-7 w-full relative">
                        <EventContent ndk={$ndk} event={article} {content} class="prose" />

                        {#if !isFullVersion}
                            <div class="absolute bottom-0 right-0 bg-gradient-to-t from-black to-transparent via-black/70 w-full h-2/3 flex flex-col items-center justify-center">
                                <UpgradeButton event={article} />
                            </div>
                        {/if}
                    </article>
                </div>
            </div>
        </div>
    </div>
</div>

{#if $debugMode}
    <pre>{JSON.stringify(article.rawEvent().tags, null, 4)}</pre>
{/if}

<style lang="postcss">
    :global(.float-element) {
        box-shadow: 0 0 10px #000;
    }

    :global(.article pre) {
        @apply whitespace-normal mb-4;
    }
</style>