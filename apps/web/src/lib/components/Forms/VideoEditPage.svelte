<script lang="ts">
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { NDKVideo, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { getUserSupportPlansStore } from "$stores/user-view";
	import VideoEditor from './VideoEditor.svelte';

    export let video: NDKVideo;
    export let teaser: NDKVideo | undefined = undefined;

    let tiers: Record<string, boolean> = { "Free": true };

    const allTiers = getUserSupportPlansStore();

    let publishingAllowed = false;
    let publishButtonTooltip = "Initializing";

    $: for (const tier of $allTiers) {
        if (tiers[tier.title] === undefined) {
            tiers[tier.title] = true;
        }
    }

    $: {
        const someTierSelected = Object.keys(tiers).filter(tier => tiers[tier]).length > 0;
        publishingAllowed = false;

        if (!someTierSelected) {
            publishButtonTooltip = "Select at least one tier";
        } else if (!video.title) {
            publishButtonTooltip = "Add a title";
        } else {
            publishButtonTooltip = "Publish";
            publishingAllowed = true;
        }
    }
</script>

<div class="flex flex-col gap-10">
    <PageTitle title="New Video" />

    <VideoEditor bind:video bind:tiers />
</div>
