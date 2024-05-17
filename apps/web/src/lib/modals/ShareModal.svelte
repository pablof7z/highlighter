<script lang="ts">
	import ItemLink from "$components/Events/ItemLink.svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import Input from "$components/Forms/Input.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { urlSuffixFromTagId, urlSuffixFromEvent, urlFromEvent } from "$utils/url";
	import { ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKEvent, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { closeModal } from '$utils/modal';
	import { NavigationOption } from "../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import { Block, Button, Link, Segmented, SegmentedButton, Toolbar } from "konsta/svelte";
    import { Share as ShareIcon } from "phosphor-svelte";
    import { Share } from '@capacitor/share';

    export let event: NDKEvent;

    let article: NDKArticle | undefined = undefined;
    let summary: string | undefined;
    let placeholder: string = "Write something";

    let content: string;

    if (event.kind === NDKKind.Article) {
        article = NDKArticle.from(event);
        summary = article.summary;
        placeholder = `What did you think of ${article.title}?`;
    }

    // Check if there is a preview version
    const preview = event.getMatchingTags("preview")[0];
    const previewId = preview?.[1];
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

    async function publish() {
        publishing = true;
        const boostEvent = new NDKEvent($ndk);
        const boostedEvent = previewEvent ?? event;
        boostEvent.kind = NDKKind.Text;
        boostEvent.content = `${content}\n\nnostr:${event.encode()}`;
        if (articleUrl)
            boostEvent.content += `\n\n${articleUrl}`;

        boostEvent.tag(boostedEvent, "mention", false, "q");
        if (boostedEvent.kind !== NDKKind.Text) boostEvent.tags.push(["k", boostedEvent.kind!.toString()]);
        boostEvent.tag(boostedEvent.author);
        try {
            await boostEvent.publish();
            closeModal();
        } finally {
            publishing = false;
        }
    }

    let advanced = false;

    let options: NavigationOption[] = [
        {
            name: "Publish on Nostr",
        },
        {
            name: "Share manually",
        },
    ];
    let selectedOption = 'Publish on Nostr';
    let activeSegmented = 1;
</script>

<ModalShell color="glassy" class="w-full max-w-2xl items-stretch">
    <Toolbar top>
        <div class="left">
            <Link onClick={() => closeModal()}>
                Close
            </Link>
        </div>

        <div class="right">
            <Button onClick={publish}>
                {#if publishing}
                    Publishing...
                {:else}
                    Publish
                {/if}
            </Button>
        </div>
    </Toolbar>
    
    <Block>
    <div class="w-full {advanced ? "max-sm:hidden" : ""}">
        <div class="w-fit basis-0 sm:bg-black p-1 rounded-full mb-4">
            <HorizontalOptionsList bind:value={selectedOption} {options} />
        </div>

        {selectedOption}

        {#if selectedOption === "Publish on Nostr"}
            <ContentEditor
                bind:content
                toolbar={false}
                {placeholder}
                allowMarkdown={false}
                class="
                    w-full min-h-[10rem]
                    {$$props.class??""}
                "
            />

            <div class="w-full max-sm:hidden">
                {#if article}
                    <ItemLink event={article} />
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

        {#await Share.canShare() then canShare}
            {#if canShare}
                <Link onClick={async () => {
                    await Share.share({
                        title: article?.title,
                        text: summary,
                        url: articleUrl,
                    });
                }}>
                    <ShareIcon class="w-8 h-8" />
                </Link>
            {/if}
        {/await}
    </Block>
</ModalShell>