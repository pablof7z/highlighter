<script lang="ts">
	import { page } from "$app/stores";
	import ArticleCard from "$components/Events/ArticleCard.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { urlSuffixFromTagId, urlSuffixFromEvent } from "$utils/url";
	import { Avatar, Name, Textarea, ndk, user } from "@kind0/ui-common";
	import { NDKArticle, NDKEvent, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { closeModal } from "svelte-modals";

    export let event: NDKEvent;

    let article: NDKArticle;
    let summary: string | undefined;

    let content: string;

    if (event.kind === NDKKind.Article) {
        article = NDKArticle.from(event);
    }

    // Check if there is a preview version
    const preview = event.getMatchingTags("preview")[0];
    const previewId = preview?.[1];
    let previewEvent: NDKEvent | undefined;

    const suffixUrl = previewId ? urlSuffixFromTagId(previewId) : urlSuffixFromEvent(event);
    let authorUrl: string;
    let articleUrl: string;
    const domain = $page.url.protocol + "://" + $page.url.hostname;

    if (preview) {
        $ndk.fetchEvent(preview[1]).then((p) => {
            if (!p) return;
            previewEvent = p;
            const previewArticle = NDKArticle.from(previewEvent);
            summary = previewArticle.summary ?? previewArticle.content;
        })
    }

    $: articleUrl = `${domain}${authorUrl}/${suffixUrl}`;

    async function publish() {
        const boostEvent = new NDKEvent($ndk);
        boostEvent.kind = NDKKind.Text;
        boostEvent.content = `${content}\n\n${articleUrl}`;
        boostEvent.tag(previewEvent || event);
        await boostEvent.sign();
        console.log(boostEvent.rawEvent());
    }
</script>

<ModalShell color="black" class="w-full max-w-2xl">
    <div class="justify-start items-center gap-4 flex w-full">
        <UserProfile user={$user} let:userProfile>
            <div class="w-12 h-12 relative">
                <Avatar {userProfile} user={$user} class="w-12 h-12 border border-white" />
            </div>
            <div class="flex flex-col gap-1 items-start">
                <div class="text-white text-[15px] font-semibold">
                    <Name {userProfile} user={$user} />
                </div>
            </div>
        </UserProfile>
    </div>

    <UserProfile user={event.author} bind:authorUrl>
        <Textarea
            class="w-full rounded-md border !border-base-300 text-lg min-h-[10rem] !bg-transparent max-h-[50vh]"
            placeholder="What did you think of this article?"
            bind:value={content}
        />

        <ArticleCard {article} />
    </UserProfile>

    <div class="flex flex-row justify-between gap-8 w-full">
        <button class="button button-primary" on:click={() => closeModal()}>Cancel</button>
        <button class="button px-10" on:click={publish}>Publish</button>
    </div>
</ModalShell>