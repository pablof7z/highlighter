<script lang="ts">
    import { NDKVideo } from "@nostr-dev-kit/ndk";
	import { getUserSupportPlansStore } from "$stores/user-view";
	import VideoEditor from './VideoEditor.svelte';

    export let video: NDKVideo;
    export let teaser: NDKVideo | undefined = undefined;

    let tiers: Record<string, boolean> = { "Free": true };

    const allTiers = getUserSupportPlansStore();

    $: for (const tier of $allTiers) {
        const dTag = tier.tagValue("d");
        if (dTag && tiers[dTag] === undefined) {
            tiers[dTag] = false;
        }
    }
</script>

<div class="flex flex-col gap-10">
    <VideoEditor bind:video />
</div>
