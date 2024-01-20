<script lang="ts">
	import { RelativeTime } from '@kind0/ui-common';
	import { NDKArticle, NDKVideo } from '@nostr-dev-kit/ndk';
    import AvatarWithName from '$components/User/AvatarWithName.svelte';
    import { Headphones, TextAlignLeft } from 'phosphor-svelte';

    export let item: NDKArticle | NDKVideo;

    const author = item.author;

    const isVideo = item instanceof NDKVideo;
    const isArticle = item instanceof NDKArticle;
</script>

<div class="flex flex-row gap-6 justify-between items-center w-full">
    <div class="flex flex-row gap-6 items-center max-sm:justify-between max-sm:w-full">
        <AvatarWithName user={author} spacing="gap-4" />
        <RelativeTime event={item} class="text-sm opacity-60" />
    </div>

    {#if isVideo}
        <div class="tooltip tooltip-left max-sm:hidden" data-tip="Coming soon">
            <button class="btn btn-neutral !rounded-full">
                <TextAlignLeft size={24} />
                Transcript
            </button>
        </div>
    {:else if isArticle}
        <div class="tooltip tooltip-left max-sm:hidden" data-tip="Coming soon">
            <button class="btn btn-neutral !rounded-full">
                <Headphones size={24} />
                Listen
            </button>
        </div>
    {/if}
</div>