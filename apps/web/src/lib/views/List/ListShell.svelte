<script lang="ts">
	import ArticleView from "$components/ArticleView.svelte";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import ListViewContent from "$components/ListViewContent.svelte";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { appMobileView } from "$stores/app";
	import { loadedEvent, title } from "$stores/item-view";
	import { layoutMode, resetLayout } from "$stores/layout";
	import { eventToKind, isEventFullVersion } from "$utils/event";
	import { getAuthorUrl } from "$utils/url";
	import { ndk } from "$stores/ndk.js";
    import { NDKArticle, NDKEvent, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";
	import { Block } from "konsta/svelte";
	import { onDestroy } from "svelte";

    export let list: NDKList;
    export let activeItemId: string | undefined = undefined;
    export let activeEvent: NDKEvent | NDKArticle | NDKVideo | NDKList | undefined | null = undefined;

    $layoutMode = "full-width";

    onDestroy(resetLayout);

    let authorUrl: string;
    let urlPrefix: string;
    let _activeItemId: string | undefined;

    getAuthorUrl(list.author).then(url => authorUrl = url);

    $: urlPrefix = [authorUrl, list.tagValue("d")].join("/");

    $: if (activeItemId !== _activeItemId) {
        _activeItemId = activeItemId;
        activeEvent = undefined;

        // Find the active tag in the items of the list
        // either by the dTag or by the full ID
        const tag = list.items.find(tag => {
            const [ kind, pubkey, dTag ] = tag[1].split(":");
            return dTag === activeItemId || tag[1] === activeItemId;
        });

        // If we found something, fetch the event
        if (tag) {
            $ndk.fetchEventFromTag(tag).then(event => {
                if (!event) return;
                activeEvent = eventToKind(event);
                $loadedEvent = event;
                
                $title = event?.title;
            });
        }
    }
</script>

{#if $appMobileView}
    {#if activeItemId}
        <LoadingScreen ready={!!activeEvent}>
            {#if activeEvent instanceof NDKArticle}
                <ArticleView
                    article={activeEvent}
                    isFullVersion={isEventFullVersion(activeEvent)}
                />
                
            {/if}
        </LoadingScreen>
    {:else}
        <Block>
            <ListViewContent {list} {urlPrefix} />
        </Block>
    {/if}
{:else}
    <div class="lg:flex flex-row flex-nowrap">
        <div class="lg:w-[var(--sidebar-width)]">
            <div class="discussion-wrapper border">
                <ListViewContent {list} {urlPrefix} />

            </div>
        </div>

        {#if activeEvent}
            <div class="flex flex-col lg:w-[var(--content-focused-width)]">
                <ArticleView
                    article={NDKArticle.from(activeEvent)}
                    isFullVersion={isEventFullVersion(activeEvent)}
                />
            </div>
        {/if}
    </div>
{/if}