<script lang="ts">
	import PageTitle from "$components/Page/PageTitle.svelte";
    import Input from "$components/Forms/Input.svelte";
	import { Textarea, ndk, user } from "@kind0/ui-common";
	import SelectTier from "$components/Forms/SelectTier.svelte";
	import { NDKArticle, NDKEvent, NDKKind, NDKList, NDKRelaySet, type NostrEvent } from "@nostr-dev-kit/ndk";

    let title: string;
    let content: string;
    let previewTitle: string;
    let previewContent: string;
    let tiers: Record<string, boolean> = { "Free": false, "Premium": true, "Exclusive": true };
    let nonSubscribersPreview = true;

    let previewTitleChanged = false;
    let previewContentChanged = false;

    $: if (!previewTitleChanged) { previewTitle = title; }
    $: if (!previewContentChanged) { previewContent = content; }

    async function publish() {
        const relaySet = NDKRelaySet.fromRelayUrls([
            'wss://relay.getfaaans.com'
        ], $ndk);

        const article = new NDKArticle($ndk, {
            content,
        } as NostrEvent);
        article.title = title;
        article.relay = Array.from(relaySet.relays)[0];
        await article.publish(relaySet);

        let previewArticle: NDKArticle | undefined;

        // Don't create a preview article if all tiers are selected
        if (Object.keys(tiers).filter(tier => tiers[tier]).length === Object.values(tiers).length) {
            nonSubscribersPreview = false;
        }

        // Create a preview article if necessary
        if (nonSubscribersPreview) {
            previewArticle = new NDKArticle($ndk, {
                content: previewContent,
            } as NostrEvent);
            previewArticle.title = previewTitle;
            previewArticle.relay = Array.from(relaySet.relays)[0];
            await previewArticle.publish(relaySet);
        }

        const tierEvents = Array.from(await $ndk.fetchEvents(
            {kinds: [NDKKind.CurationSet], authors: [$user.pubkey]},
            {},
            relaySet
        ))

        // Go through the tiers and publish the article to each one
        for (const tier in tiers) {
            if (!previewArticle && !tiers[tier]) continue;

            let tierEvent;// = tierEvents.find((event: NDKEvent) => event.tagValue("d") === tier);
            let tierList: NDKList;
            if (tierEvent) {
                tierList = NDKList.from(tierEvent);
            } else {
                tierList = new NDKList($ndk, {
                    kind: NDKKind.CurationSet,
                    tags: [ [ "d", tier ] ],
                } as NostrEvent);
                tierList.title = title;
            }

            const articleToAdd = tiers[tier] ? article : previewArticle;

            tierList.tags.unshift(articleToAdd?.tagReference()!);
            await tierList.publish(relaySet);
        }
    }

    function preview() {
    }
</script>


<div class="flex flex-col gap-10">
    <PageTitle title="New Article">
        <div class="flex flex-row gap-2">
            <!-- <button on:click={preview} class="button button-primary">Preview</button>
            <button on:click={preview} class="button button-primary">Save Draft</button> -->
            <button on:click={publish} class="button px-10">Publish</button>
        </div>
    </PageTitle>

    <div class="w-full flex-col justify-start items-start inline-flex">
        <Input
            bind:value={title}
            class="!bg-transparent border border-neutral-800 rounded-xl text-white text-xl rounded-b-none"
            placeholder="Title"
        />
        <Textarea
            bind:value={content}
            class="w-full !bg-transparent border border-neutral-800 rounded-xl rounded-t-none resize-none min-h-[50vh] text-lg text-white font-serif tracking-widest"
        />
    </div>

    <SelectTier bind:tiers />

    <div class="flex flex-col gap-4" class:hidden={tiers["Free"]}>
        <label class="text-white text-base font-medium flex flex-row gap-2 items-start border border-neutral-800 px-4 py-3 rounded-xl">
            <input type="checkbox" class="checkbox mr-2" bind:checked={nonSubscribersPreview} />
            <div class="flex flex-col items-start">
                Non-subscribers Teaser
                <div class="text-neutral-500 text-sm">Allow non-subscribers to preview this article</div>
            </div>
        </label>

        <div class:hidden={!nonSubscribersPreview} class="transition-all duration-300">
            <Input
                bind:value={previewTitle}
                on:change={() => previewTitleChanged = true}
                class="!bg-transparent border border-neutral-800 rounded-xl text-white text-xl rounded-b-none"
                placeholder="Title"
            />
            <Textarea
                bind:value={previewContent}
                on:change={() => previewContentChanged = true}
                class="w-full !bg-transparent border border-neutral-800 rounded-xl rounded-t-none resize-none min-h-[50vh] text-lg text-white font-serif tracking-widest"
            />
        </div>
    </div>
</div>