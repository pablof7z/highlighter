<script lang="ts">
    import { NDKEvent, NDKHighlight, NDKTag } from "@nostr-dev-kit/ndk";
    import { ndk } from "$stores/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
    import sanitizeHtml from "sanitize-html";
	import HighlightedContent from "./HighlightedContent.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import HighlightingArea from "../HighlightingArea.svelte";
	import { getContext } from "svelte";
	import { derived, Readable, Writable } from "svelte/store";
	import * as Content from "$components/Content";
	import EmbeddedEventWrapper from "$components/Events/EmbeddedEventWrapper.svelte";
	import { ArticleSettings } from ".";
	import currentUser from "$stores/currentUser";
	import { wot } from "$stores/wot";

    export let article: NDKEvent;
    export let isPreview = false;
    export let isFullVersion = true;

    const settings = getContext('settings') as Writable<ArticleSettings>;

    $: isFullVersion = !article.tagValue('full');

    const highlights = getContext('highlights') as Readable<NDKHighlight[]>;

    let el: HTMLDivElement;

    const visibleHighlights = derived(
        [highlights, settings, currentUser],
        ([$highlights, $settings, $currentUser]) => {
            return $highlights.filter((hl) => {
                if ($settings.highlights.byUser && hl.pubkey === $currentUser?.pubkey) return true;
                if ($settings.highlights.byNetwork && $wot.has(hl.pubkey)) return true;
                if ($settings.highlights.outOfNetwork && $currentUser?.pubkey !== hl.pubkey && !$wot.has(hl.pubkey)) return true;
                return false;
            });
        }
    );

    let resetView: () => void;

    let byUser = $settings.highlights.byUser;
    let byNetwork = $settings.highlights.byNetwork;
    let outOfNetwork = $settings.highlights.outOfNetwork;

    $: if (resetView) {
        if ($settings.highlights.byUser !== byUser || $settings.highlights.byNetwork !== byNetwork || $settings.highlights.outOfNetwork !== outOfNetwork) {
            resetView();
        }
    }
</script>

<div class="break-inside max-sm:ml-4 max-sm:mr-12 relative lg:-mx-4 lg:px-4" bind:this={el}>
    {#if !isPreview}
        <HighlightingArea>
            <HighlightedContent bind:resetView event={article} highlights={visibleHighlights} />

            {#if !isFullVersion}
                <div class="absolute bottom-0 right-0 bg-gradient-to-t from-background to-transparent via-background/70 w-full h-full flex flex-col items-center justify-center">
                    <UpgradeButton event={article} />
                </div>
            {/if}
        </HighlightingArea>
    {:else}
        <EventContent
            ndk={$ndk}
            event={article}
            class="prose-lg leading-8"
            eventCardComponent={EmbeddedEventWrapper}
            sanitizeHtmlOptions={{ allowedTags: sanitizeHtml.defaults.allowedTags.concat(["img", "mark", "del"])}}
        />
    {/if}
</div>

{#if !isPreview}
    <div class=" min-h-[20rem]" id="comments-container">
        <Content.Views.Comments wrappedEvent={article} />
    </div>
{/if}
