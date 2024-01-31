<script lang="ts">
	import VideoPreviewEditorModal from '$modals/VideoPreviewEditorModal.svelte';
	import PublishingStep from './Pages/PublishingStep.svelte';
	import { fade } from 'svelte/transition';
    import UserProfile from '$components/User/UserProfile.svelte';
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { NDKVideo, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { debugMode } from "$stores/session";
    import DistributionPage from "./Pages/DistributionPage.svelte";
	import { getDefaultRelaySet } from '$utils/ndk';
	import { publishToTiers } from '$actions/publishToTiers';
    import Page1 from "./VideoEditorPage/Page1.svelte";
    import Page2 from "./VideoEditorPage/Page2.svelte";
	import ItemEditShell from '../Forms/ItemEditShell.svelte';
	import { type TierSelection, getSelectedTiers, getTierSelectionFromAllTiers } from '$lib/events/tiers';
	import { getUserSupportPlansStore } from '$stores/user-view';
	import { openModal } from 'svelte-modals';

    export let video: NDKVideo = new NDKVideo($ndk, {
        content: "",
    } as NostrEvent);
    export let teaser: NDKVideo = new NDKVideo($ndk);

    let tiers: TierSelection = { "Free": { name: "Free", selected: true } };
    const allTiers = getUserSupportPlansStore();
    $: tiers = getTierSelectionFromAllTiers($allTiers);

    let videoFile: File | undefined;

    let step = 0;

    const domain = "https://highlighter.com";
    let authorUrl: string | undefined;

    $: teaser.content = video.content;

    function tiersChanged(e: CustomEvent<TierSelection>) {
        tiers = e.detail;
    }

    // function editTeaser() {
    //     openModal(VideoPreviewEditorModal, {
    //         video,
    //         teaser,
    //         teaserUrl: teaser.url,
    //         onUploaded: (teaserUrl) => {
    //             teaser.url = teaserUrl;
    //             wideDistribution = !!teaserUrl;
    //         }
    //     });
    // }
</script>

<UserProfile user={$user} bind:authorUrl />

<Page1
    bind:video={video}
    bind:videoFile={videoFile}
/>
{#if videoFile || video.url}
    <Page2
        {videoFile}
        bind:video
    />
{/if}