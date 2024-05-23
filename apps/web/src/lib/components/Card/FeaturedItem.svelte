<script lang="ts">
	import Carousel from "$components/Page/Carousel.svelte";
	import { Name, UserProfile, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKHighlight, NDKSubscriptionCacheUsage, NDKKind, NDKTag, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import Highlight from "$components/Highlight.svelte";
	import { urlFromEvent } from "$utils/url";
	import { Chip } from "konsta/svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";

    export let highlights: NDKHighlight[];
</script>

        {#if highlights}
            <Carousel itemCount={highlights.length} class="w-full">
                {#each highlights as highlight (highlight.id)}
                    <div class="w-[100vw] flex-none">
                        <Highlight
                            {highlight}
                            skipArticle={true}
                            compact={true}
                            skipFooter={true}
                            disableSwipe={true}
                        />
                    </div>
                {/each}
            </Carousel>
        {/if}