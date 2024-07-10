<script lang="ts">
	import { ndk } from '$stores/ndk';
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let video: NDKVideo;
    export let isPreview = false;
    export let isFullVersion = true;
    export let userProfile: NDKUserProfile | undefined | null;
    export let authorUrl: string;
</script>

<EventContent
    ndk={$ndk}
    event={video}
    class="prose-lg leading-8"
/>