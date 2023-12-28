<script lang="ts">
	import EventResponses from '$components/EventResponses.svelte';
	import { goto } from "$app/navigation";
	import EventActionButtons from "$components/buttons/EventActionButtons.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { debugMode, userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription, userTiers } from "$stores/user-view";
	import { ndk, pageDrawerToggle, rightSidebar, user, HighlightWrapper } from "@kind0/ui-common";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { onDestroy, onMount } from "svelte";
	import { openModal } from "svelte-modals";
	import { addReadReceipt } from '$utils/read-receipts';

    export let article: NDKArticle;
    const author = article.author;

    onMount(() => {
        startUserView(author);
        addReadReceipt(article);
    });

    onDestroy(() => {
        userSubscription?.unref();
    });

    // Check if this suer has access to the full article and if they do, redirect them to the full article
    const fullTiers = article.getMatchingTags("tier").map(t => t[1]);

    $: if (fullTiers.includes($userActiveSubscriptions.get(article.pubkey))) {
        const parts = article.tagValue("full")?.split(/:/) as string[];
        const dTag = parts[2] || parts[0];
        goto(`/${author.npub}/${dTag}`);
    }

    const isTeaser = !!article.tagValue("full");

    let content = article.content;

    let editUrl = `/articles/${article.tagValue("d")}/edit`;

    function selectionchange(event: CustomEvent) {
        const d = event.detail;
        console.log(d);
    }

    onMount(() => {
        document.addEventListener('click', function(event) {
            // remove the floating element
            let floatElement = document.querySelector('.float-element');
            if (floatElement) {
                floatElement.remove();
            }
        });
        document.addEventListener('mouseup', function(event) {
            let selection = window.getSelection();
            if (selection.toString().length > 0) {
                let range = selection.getRangeAt(0);
                let rect = range.getBoundingClientRect();

                // Create the floating element
                let floatElement = document.createElement('div');
                floatElement.textContent = "Your Content Here";
                floatElement.className = 'float-element';
                floatElement.style.position = 'absolute';
                floatElement.style.top = (rect.top + window.scrollY - 50) + 'px';
                floatElement.style.left = (rect.right + window.scrollX) + 'px';
                setTimeout(() => {
                    el?.appendChild(floatElement);
                }, 100)
            }
        });


    })

    let el: HTMLDivElement;
</script>

<svelte:head>
    <title>{article.title}</title>
</svelte:head>

<div bind:this={el} class="z-50" />

<div class="max-">
    {#if article.image}
        <div class="w-full max-h-[50vh] relative overflow-hidden">
            <img class="w-full relative sm:rounded-xl object-cover object-top h-full" src={article.image} />
            <div class="absolute bottom-0 w-full h-2/5 bg-gradient-to-b from-transparent to-black"></div>
        </div>
    {/if}

    <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4">
        <div class="self-stretch justify-center items-start gap-8 inline-flex">
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
                <div class="self-stretch flex-col justify-center items-start gap-6 flex">
                    <div class="self-stretch flex-col justify-start items-start gap-6 flex">
                        <div class="self-stretch text-white text-2xl font-medium">
                            {article.title}
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
                            <div class="text-white text-opacity-60 text-sm font-normal leading-[21px]">32 responses  108 boosts</div>
                        </div>
                    </div>
                    <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-7 w-full relative">
                        <EventContent ndk={$ndk} event={article} {content} />

                        {#if isTeaser}
                            <div class="absolute bottom-0 right-0 bg-gradient-to-t from-black to-transparent via-black/70 w-full h-2/3 flex flex-col items-center justify-center">
                                <UpgradeButton event={article} />
                            </div>
                        {/if}
                    </div>
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
        background-color: #fff;
        border: 1px solid #000;
        padding: 10px;
        border-radius: 5px;
        box-shadow: 0 0 10px #000;
    }

    :global(.article pre) {
        @apply whitespace-normal mb-4;
    }
</style>