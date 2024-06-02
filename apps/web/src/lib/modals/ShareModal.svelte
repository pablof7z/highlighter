<script lang="ts">
	import { BlossomClient } from 'blossom-client-sdk/client';
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import Input from "$components/Forms/Input.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import { urlSuffixFromTagId, urlSuffixFromEvent, urlFromEvent } from "$utils/url";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKEvent, NDKKind, NDKRelaySet, NDKTag, NDKUser } from "@nostr-dev-kit/ndk";
	import { closeModal } from '$utils/modal';
	import { NavigationOption } from "../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { Block, Button, Link, Segmented, SegmentedButton, Toolbar } from "konsta/svelte";
    import { Export, Share as ShareIcon } from "phosphor-svelte";
    import { Share } from '@capacitor/share';
	import { appMobileView } from "$stores/app";
	import ShareImage from "$components/Event/ShareImage.svelte";
    import { toBlob, toPng } from "html-to-image";
	import { EventTemplate } from "nostr-tools";
	import { activeBlossomServer } from '$stores/session';
	import { onDestroy } from 'svelte';

    export let event: NDKEvent;
    export let content: string = "";
    export let tags: NDKTag[] = [];

    let article: NDKArticle | undefined = undefined;
    let summary: string | undefined;
    let placeholder: string = "Write something";

    if (event.kind === NDKKind.Article) {
        article = NDKArticle.from(event);
        summary = article.summary;
        placeholder = `What did you think of ${article.title}?`;
    }

    // Check if there is a preview version
    const preview = event.getMatchingTags("preview")[0];
    let previewEvent: NDKEvent | undefined;

    const articleUrl = urlFromEvent(event, undefined, true);

    if (preview) {
        $ndk.fetchEvent(preview[1]).then((p) => {
            if (!p) return;
            previewEvent = p;
            const previewArticle = NDKArticle.from(previewEvent);
            summary = previewArticle.summary ?? previewArticle.content;
        })
    }

    let publishing = false;

    async function sign(draft: EventTemplate) {
        const e = new NDKEvent($ndk, draft as any);
        await e.sign();
        return e.toNostrEvent();
    }

    async function uploadImage() {
        const uploadAuth = await BlossomClient.getUploadAuth( file!, sign as any, "Upload share image");
        const res = await BlossomClient.uploadBlob($activeBlossomServer, file!, uploadAuth);
        const mediaEvent = new NDKEvent($ndk);
        mediaEvent.kind = NDKKind.Media;
        mediaEvent.content = event.tagValue("title") ?? "";
        if (res.type) mediaEvent.tags.push(["m", res.type]);
        if (res.sha256)mediaEvent.tags.push(["x", res.sha256]);
        if (res.url) mediaEvent.tags.push(["url", res.url]);
        if (res.size) mediaEvent.tags.push(["size", res.size.toString()]);
        mediaEvent.tag(event!);
        await mediaEvent.publish();

        return res.url;
    }

    async function getCoverImageUrl() {
        const cover = await $ndk.fetchEvent({
            kinds: [NDKKind.Media], ...event.filter(), authors: [event.pubkey], limit: 1
        });

        if (cover) return cover.tagValue("url");
    }

    let coverImageUrl: string | undefined;
    getCoverImageUrl().then((url) => coverImageUrl = url);

    async function publish() {
        publishing = true;
        const boostEvent = new NDKEvent($ndk);
        const boostedEvent = previewEvent ?? event;
        boostEvent.kind = NDKKind.Text;
        boostEvent.content = `${content}\n\nnostr:${event.encode()}`;

        try {
            coverImageUrl ??= await uploadImage();
            if (coverImageUrl) {
                boostEvent.content += `\n\n${coverImageUrl}`;
            }
        } catch (e) {
            console.error(e);
        }
        
        if (articleUrl)
            boostEvent.content += `\n\n${articleUrl}`;

        boostEvent.tag(boostedEvent, "mention", false, "q");
        
        for (const tag of tags) {
            boostEvent.tags.push(tag);
        }
        if (boostedEvent.kind !== NDKKind.Text) boostEvent.tags.push(["k", boostedEvent.kind!.toString()]);
        boostEvent.tag(boostedEvent.author);
        await boostEvent.sign();
        console.log(boostEvent.rawEvent());
        const relaySet = NDKRelaySet.fromRelayUrls(["ws://localhost:5577"], $ndk);
        try {
            await boostEvent.publish(relaySet);
            closeModal();
        } finally {
            publishing = false;
        }
    }

    let advanced = false;

    let options: NavigationOption[] = [
        { name: "Publish on Nostr", },
        { name: "Share manually", },
    ];

    let selectedOption = 'Publish on Nostr';

    let shareImageEl: HTMLElement;
</script>

<ModalShell
    title="Share"
    class="w-full max-w-2xl items-stretch"
    mobileToolbar={[
        { name: publishing ? "Publishing" : "Publish", fn: publish }
    ]}
>
    <svelte:fragment slot="titleRight">
        <div class="flex flex-row items-center">
            <HorizontalOptionsList bind:value={selectedOption} {options} />
            {#await Share.canShare() then canShare}
                {#if canShare?.value}
                    <button on:click={async () => {
                        await Share.share({
                            title: article?.title,
                            text: summary,
                            url: articleUrl,
                        });
                    }}>
                        <Export class="w-8 h-8" />
                    </button>
                {/if}
            {/await}
        </div>
    </svelte:fragment>
    
    <div class="w-full {advanced ? "max-sm:hidden" : ""}">
        {#if selectedOption === "Publish on Nostr"}
            <ContentEditor
                bind:content
                toolbar={false}
                autofocus
                allowMarkdown={false}
                class="
                    w-full min-h-[10rem]
                    {$$props.class??""}
                "
            />

            <div class="w-full">
                {#if article}
                    <ShareImage {article} bind:node={shareImageEl} />
                {:else}
                    <div class="border border-base-300 rounded-box w-full">
                        <EventWrapper
                            {event}
                            expandReplies={false}
                            expandThread={false}
                            skipFooter={true}
                            skipReply={true}
                            showReply={false}
                            compact={true}
                        />
                    </div>
                {/if}
            </div>
        {:else}
            <div class="w-full">
                <div class="flex flex-col items-start gap-2 w-full">
                    <div class="font-normal text-left w-full">URL</div>

                    <Input
                        color="black"
                        value={articleUrl}
                        class="w-full rounded-md border !border-base-300 !bg-transparent font-mono"
                        readonly
                    />
                </div>

                <div class="flex flex-col items-start gap-2 w-full">
                    <div class="font-normal text-left w-full">Nostr Address</div>

                    <Input
                        color="black"
                        value={`nostr:${event.encode()}`}
                        class="w-full rounded-md border !border-base-300 !bg-transparent font-mono"
                        readonly
                    />
                </div>
            </div>
        {/if}
    </div>

    <svelte:fragment slot="footer">
        <button class="button px-6" on:click={publish}>
            {#if publishing}
                Publishing...
            {:else}
                Publish
            {/if}
        </button>
    </svelte:fragment>
</ModalShell>