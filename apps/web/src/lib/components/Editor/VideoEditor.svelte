<script lang="ts">
    import UserProfile from '$components/User/UserProfile.svelte';
	import { ndk, user } from "@kind0/ui-common";
	import { NDKVideo, type NostrEvent } from "@nostr-dev-kit/ndk";
    import Page1 from "./VideoEditorPage/Page1.svelte";
	import { type TierSelection, getTierSelectionFromAllTiers } from '$lib/events/tiers';
	import { getUserSubscriptionTiersStore } from '$stores/user-view';

    export let video: NDKVideo = new NDKVideo($ndk, {
        content: "",
    } as NostrEvent);
    export let videoFile: File | undefined;
    export let teaser: NDKVideo = new NDKVideo($ndk);

    let tiers: TierSelection = { "Free": { name: "Free", selected: true } };
    const allTiers = getUserSubscriptionTiersStore();
    $: tiers = getTierSelectionFromAllTiers($allTiers);

    const domain = "https://highlighter.com";
    let authorUrl: string | undefined;

    $: teaser.content = video.content;
</script>

<UserProfile user={$user} bind:authorUrl />

<Page1
    bind:video={video}
    bind:videoFile={videoFile}
/>
