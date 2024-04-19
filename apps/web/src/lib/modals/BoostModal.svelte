<script lang="ts">
	import { page } from "$app/stores";
	import ArticleCard from "$components/Events/ArticleCard.svelte";
	import ItemLink from "$components/Events/ItemLink.svelte";
	import ForumFeedItem from "$components/Feed/ForumFeedItem.svelte";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import Input from "$components/Forms/Input.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { urlSuffixFromTagId, urlSuffixFromEvent } from "$utils/url";
	import { Avatar, Name, Textarea, ndk, user } from "@kind0/ui-common";
	import { NDKArticle, NDKEvent, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { CaretDown } from "phosphor-svelte";
	import { closeModal } from "svelte-modals";
	import { slide } from "svelte/transition";

    export let event: NDKEvent;

    let article: NDKArticle | undefined = undefined;
    let summary: string | undefined;
    let placeholder: string = "Write something";

    let content: string;

    if (event.kind === NDKKind.Article) {
        article = NDKArticle.from(event);
        placeholder = `What did you think of ${article.title}?`;
    }

    // Check if there is a preview version
    const preview = event.getMatchingTags("preview")[0];
    const previewId = preview?.[1];
    let previewEvent: NDKEvent | undefined;

    const suffixUrl = previewId ? urlSuffixFromTagId(previewId) : urlSuffixFromEvent(event);
    let authorUrl: string;
    let articleUrl: string | undefined;
    const domain = $page.url.protocol + "://" + $page.url.hostname;

    if (preview) {
        $ndk.fetchEvent(preview[1]).then((p) => {
            if (!p) return;
            previewEvent = p;
            const previewArticle = NDKArticle.from(previewEvent);
            summary = previewArticle.summary ?? previewArticle.content;
        })
    }

    $: if (article) articleUrl = `${domain}${authorUrl}/${suffixUrl}`;

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
</script>

<ModalShell color="glassy" class="w-full max-w-2xl items-stretch">
    <h1 class="w-full text-left text-xl font-bold">Publish on Nostr</h1>

    <UserProfile user={event.author} bind:authorUrl>
        <ContentEditor
            bind:content
            toolbar={false}
            {placeholder}
            allowMarkdown={false}
            autofocus={true}
            class="
                w-full min-h-[15rem]
                border border-white/10 rounded-box
                {$$props.class??""}
            "
        />

        {#if article}
            <ArticleCard {article} />
        {:else}
            <div class="bg-base-300 rounded-box w-full px-4">
                <ForumFeedItem {event} />
            </div>
        {/if}
    </UserProfile>

    <div class="flex flex-row items-stretch justify-end gap-8 w-full">
        <button class="inline-flex flex-row gap-2" on:click={() => advanced = !advanced}>
            Share manually
            <span class="duration-300 transition-all" class:rotate-180={advanced}>
                <CaretDown class="w-6 h-6" />
            </span>
        </button>

        <div class="grow"></div>

        <button class="" on:click={() => closeModal()}>Cancel</button>
        <button class="button px-10" on:click={publish}>
            {#if publishing}
                Publishing...
            {:else}
                Publish
            {/if}
        </button>
    </div>

    {#if advanced}
        <div class="w-full" transition:slide>
            <div class="divider">OR</div>

            <h1 class="w-full text-left text-3xl font-bold">Share manually</h1>

            <div class="flex flex-col items-start gap-2 w-full">
                <div class="font-normal text-left w-full">Share URL</div>

                <Input
                    color="black"
                    value={articleUrl}
                    class="w-full rounded-md border !border-base-300 !bg-transparent font-mono"
                    readonly
                />
            </div>

            <div class="flex flex-col items-start gap-2 w-full">
                <div class="font-normal text-left w-full">Share Nostr Address</div>

                <Input
                    color="black"
                    value={`nostr:${event.encode()}`}
                    class="w-full rounded-md border !border-base-300 !bg-transparent font-mono"
                    readonly
                />
            </div>
        </div>
    {/if}
</ModalShell>