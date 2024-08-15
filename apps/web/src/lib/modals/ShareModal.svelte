<script lang="ts">
	import { BlossomClient } from 'blossom-client-sdk/client';
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import Input from '$components/ui/input/input.svelte';
    import ModalShell from "$components/ModalShell.svelte";
	import { urlFromEvent } from "$utils/url";
	import { ndk } from "$stores/ndk.js";
	import { NDKArticle, NDKEvent, NDKKind, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
	import { closeModal } from '$utils/modal';
	import { NavigationOption } from "../../app";
    import { Export } from "phosphor-svelte";
    import { Share } from '@capacitor/share';
	import ShareImage from "$components/Event/ShareImage.svelte";
	import { EventTemplate } from "nostr-tools";
	import { activeBlossomServer } from '$stores/session';
    import * as Tabs from "$lib/components/ui/tabs";
	import Checkbox from '$components/Forms/Checkbox.svelte';
	import ShareImageUploader from '$components/ShareImageUploader.svelte';

    export let event: NDKEvent;
    export let content: string = "";
    export let tags: NDKTag[] = [];

    let article: NDKArticle | undefined = undefined;
    let summary: string | undefined;

    if (event.kind === NDKKind.Article) {
        article = NDKArticle.from(event);
        summary = article.summary;
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

    function onCoverImageUploaded(e: CustomEvent) {
        const url = e.detail.url;
        console.log("Cover image uploaded", url);
        coverImageUrl = url;
        publish(true);
    }

    function onCoverImageError(e: any) {
        publish(true);
    }

    async function publish(skipImageUpload = false) {
        publishing = true;

        if (!coverImageUrl && !uploadShareImage && !skipImageUpload) {
            // If we don't have a cover image, and we haven't tried to upload one yet,
            // force <ShareImageUploader /> to upload an image and continue the flow there
            // from the onCoverImageUploaded or onCoverImageError callbacks
            uploadShareImage = true;
            return;
        }
        
        const boostEvent = new NDKEvent($ndk);
        const boostedEvent = previewEvent ?? event;
        boostEvent.kind = NDKKind.Text;

        const contentParts: string[] = [content];
        contentParts.push(`nostr:${event.encode()}`);

        if (coverImageUrl) contentParts.push(coverImageUrl);
        if (articleUrl) contentParts.push(articleUrl);

        boostEvent.tag(boostedEvent, "mention", false, "q");
        
        for (const tag of tags) {
            boostEvent.tags.push(tag);
        }
        if (boostedEvent.kind !== NDKKind.Text) boostEvent.tags.push(["k", boostedEvent.kind!.toString()]);
        boostEvent.tag(boostedEvent.author);

        boostEvent.content = contentParts
            .filter(part => part.length > 0)
            .join("\n\n");
        
        try {
            await boostEvent.sign();
            boostEvent.publish();
            closeModal();
        } finally {
            publishing = false;
        }
    }

    let repost = true;
    let selectedView = "nostr";

    let actionButtons: NavigationOption[];
    let uploadShareImage = false;

    function share() {
        Share.share({
            title: article?.title,
            text: summary,
            url: articleUrl,
        });
        selectedView = "nostr";
    }

    $: if (selectedView === "nostr") {
        actionButtons = [
            { name: publishing ? "Publishing" : "Publish", fn: publish, buttonProps: { variant: 'default' } }
        ];
    } else {
        actionButtons = [];
    }
</script>

<ModalShell
    title="Share"
    class="w-full max-w-2xl items-stretch"
    mobileToolbar={[
        { name: publishing ? "Publishing" : "Publish", fn: publish }
    ]}
    {actionButtons}
>
    <Tabs.Root bind:value={selectedView} slot="titleRight">
        <Tabs.List>
            <Tabs.Trigger value="nostr">Publish on Nostr</Tabs.Trigger>
            <Tabs.Trigger value="advanced">Advanced</Tabs.Trigger>
            {#await Share.canShare() then canShare}
                {#if canShare.value}
                    <Tabs.Trigger value="extra" on:click={share}>
                        <Export class="w-5 h-5" />
                    </Tabs.Trigger>
                {/if}
            {/await}
        </Tabs.List>
    </Tabs.Root>

    <Tabs.Root bind:value={selectedView}>
        <Tabs.Content value="nostr">
            <ContentEditor
                bind:content
                toolbar={false}
                autofocus
                placeholder="Comment"
                allowMarkdown={false}
                class="
                w-full max-w-xl
                    min-h-[10rem]
                    text-lg
                    {$$props.class??""}
                "
            />
            <div class="w-full flex flex-col gap-4">
                <div class="w-full border border-border rounded overflow-clip">
                    {#if article}
                        <ShareImageUploader
                            {article}
                            forceGenerate={uploadShareImage}
                            bind:forceUpload={uploadShareImage}
                            on:uploaded={onCoverImageUploaded}
                            on:error={onCoverImageError}
                        />
                    {:else}
                        <EventWrapper
                            {event}
                            expandReplies={false}
                            expandThread={false}
                            skipFooter={true}
                            skipReply={true}
                            showReply={false}
                            compact={true}
                        />
                    {/if}
                </div>
            </div>
        </Tabs.Content>
        <Tabs.Content value="advanced">
            <div class="w-full">
                <div class="flex flex-col items-start gap-2 w-full">
                    <div class="font-normal text-left w-full">URL</div>

                    <Input
                        color="black"
                        value={articleUrl}
                        class="w-full rounded-md border !border-border !bg-transparent font-mono"
                        readonly
                    />
                </div>

                <div class="flex flex-col items-start gap-2 w-full">
                    <div class="font-normal text-left w-full">Nostr Address</div>

                    <Input
                        color="black"
                        value={`nostr:${event.encode()}`}
                        class="w-full rounded-md border !border-border !bg-transparent font-mono"
                        readonly
                    />
                </div>
            </div>
        </Tabs.Content>
    </Tabs.Root>

    <svelte:fragment slot="footerExtra">
        {#if selectedView === "nostr"}
            <Checkbox class="text-sm ml-8" bind:checked={repost}>
                Repost in 8 hours
                <span class="text-xs font-light" slot="description">
                    Reach followers in other timezones
                </span>
            </Checkbox>
        {/if}
    </svelte:fragment>
</ModalShell>