<script lang="ts">
    import { NDKVideo } from "@nostr-dev-kit/ndk";
	import { getUserSupportPlansStore } from "$stores/user-view";
	import VideoEditor from './VideoEditor.svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import Shell from "$components/PostEditor/Shell.svelte";

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

<Shell type="video" {video}>
    <VideoEditor bind:video />
</Shell>
