<script lang="ts">
	import * as Footer from "$components/Footer";
    import { NDKArticle, NDKHighlight } from "@nostr-dev-kit/ndk";
    import Zap from "$components/Footer/Buttons/Zap.svelte";
	import HighlightTool from '$components/Footer/Views/HighlightTool';
	import Bookmark from "$components/Footer/Buttons/Bookmark.svelte";
	import Comments from "$components/Footer/Buttons/Comments.svelte";
	import Highlights from "$components/Footer/Buttons/Highlights.svelte";
	import Share from "$components/Footer/Buttons/Share.svelte";
	import { activeSelection } from '$stores/highlight-tool';
	import { Readable, Writable } from "svelte/store";
	import { ArticleSettings } from ".";

    export let article: NDKArticle;
    export let highlights: Readable<NDKHighlight[]>;
    export let settings: Writable<ArticleSettings>;

    console.log('settings', settings, $settings);
</script>

<Footer.Shell
>
    <!-- <div class="absolute top-0 left-0 h-1 right-0">
        <Progress value={$scrollPercentage} class="rounded-sm h-1" barClass="dark:bg-gold light:bg-foreground" />
    </div> -->
    {#if $activeSelection}
        <HighlightTool.Toolbar event={article} />
    {:else}
        <div class="flex flex-row justify-center w-1/5"><Zap event={article} /></div>
        <div class="flex flex-row justify-center w-1/5"><Comments event={article} /></div>
        <div class="flex flex-row justify-center w-1/5"><Highlights event={article} {settings} {highlights} /></div>
        <div class="flex flex-row justify-center w-1/5"><Share event={article} /></div>
        <div class="flex flex-row justify-center w-1/5"><Bookmark event={article} /></div>
    {/if}
</Footer.Shell>