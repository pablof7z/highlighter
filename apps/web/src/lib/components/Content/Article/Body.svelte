<script lang="ts">
    import { NDKEvent, NDKHighlight, NDKTag } from "@nostr-dev-kit/ndk";
    import { ndk } from "$stores/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import HighlightedContent from "./HighlightedContent.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import HighlightingArea from "../HighlightingArea.svelte";
	import { getContext } from "svelte";
	import { derived, get, Readable, Writable } from "svelte/store";
	import EmbeddedEventWrapper from "$components/Events/EmbeddedEventWrapper.svelte";
	import { ArticleSettings } from ".";
	import currentUser from "$stores/currentUser";
	import { wot } from "$stores/wot";
    import * as Content from '$components/Content';
    import * as Groups from '$components/Groups';
    import * as Card from '$components/Card';
	import UserProfile from "$components/User/UserProfile.svelte";
	import Avatar from "$components/User/Avatar.svelte";
	import Name from "$components/User/Name.svelte";
	import MoreFrom from "$components/User/MoreFrom.svelte";
	import FeaturedCommunityCard from "$components/Card/FeaturedCommunityCard.svelte";

	// import { wot } from "$stores/wot";

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
            if (isPreview) return [];
            if (!$wot) return $highlights;
            
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

    const groupTags = article.getMatchingTags("h")

    // $: if (resetView) {
    //     if ($settings.highlights.byUser !== byUser || $settings.highlights.byNetwork !== byNetwork || $settings.highlights.outOfNetwork !== outOfNetwork) {
    //         resetView();
    //     }
    // }
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
        />
    {/if}
</div>

{#if groupTags.length > 0}
    <Groups.RootList tags={groupTags} let:group let:articles>
        {#if articles}
            <Groups.MoreFrom
                {group}
                {articles}
                skipIds={new Set(article.tagId())}
            />
        {:else}
        false
        {/if}
    </Groups.RootList>
{:else}
    <MoreFrom
        user={article.author}
        skipIds={new Set([article.tagId()])}
    />
{/if}

{#if !isPreview}
    <div class=" min-h-[20rem]" id="comments-container">
        <Content.Views.Comments wrappedEvent={article} />
    </div>
{/if}
