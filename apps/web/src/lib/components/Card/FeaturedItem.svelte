<script lang="ts">
	import Carousel from "$components/Page/Carousel.svelte";
	import { NDKHighlight } from "@nostr-dev-kit/ndk";
    import Highlight from "$components/Highlight.svelte";

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