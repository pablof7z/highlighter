<script lang="ts">
	import FeedEvent from "./FeedEvent.svelte";
	import { getGAUserContent, getUserContent } from "$stores/user-view";
	import { ndk } from "@kind0/ui-common";

    const userContent = getUserContent();
    const userGAContent = getGAUserContent();

    // const rootContent = derived(content, ($content) => {
    //     return $content;
    //     // return $content.filter(isRootEvent);
    // });
</script>

<div class="flex flex-col w-full gap-10">
        {#each $userContent as event (event.id)}
            <FeedEvent {event} skipAuthor={true} />
        {/each}
        {#each $userGAContent as event (event.id)}
            <FeedEvent {event} skipAuthor={true} />
        {/each}
</div>

<style lang="postcss">
    :global(.article p) {
        @apply font-light text-white text-opacity-60 text-lg leading-7;
    }
</style>
