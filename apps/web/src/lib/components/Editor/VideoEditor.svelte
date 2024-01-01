<script lang="ts">
	import VideoPreviewEditorModal from './../../modals/VideoPreviewEditorModal.svelte';
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
    let nonSubscribersPreview: boolean;

    let step = 2;

    let publishing = false;
    let shareUrl = "";

    async function publish() {
        publishing = true;
        const relaySet = getDefaultRelaySet();

        video.relay = Array.from(relaySet.relays)[0];

        const selectedTiers = getSelectedTiers(tiers);

        // Don't create a preview video if all tiers are selected
        if (selectedTiers.length === Object.values(tiers).length) {
            nonSubscribersPreview = false;
        }

        // Create a preview video if necessary
        if (nonSubscribersPreview) {
            teaser.relay = Array.from(relaySet.relays)[0];
            teaser.title = video.title;
            teaser.thumbnail = video.thumbnail;
            teaser.duration = video.duration;
        }

        await video.sign();
        await teaser.sign();

        try {
            await publishToTiers(video, tiers, {
                ndk: $ndk,
                teaserEvent: nonSubscribersPreview ? teaser : undefined,
                wideDistribution
            });
        } catch (e: any) {
            step--;
            publishing = false;
            newToasterMessage(e.message, "error");
            return;
        }

        video = video;
        teaser = teaser;

        const shareArticle = teaser ?? video;

        shareUrl = `${domain}${authorUrl}/${shareArticle.tagValue("d")}`;
        publishing = false;
    }

    const domain = "https://getfaaans.com";
    let authorUrl: string | undefined;

    $: teaser.content = video.content;

    let wideDistribution = true;

    let steps=[
        {
            title: "Video",
            description: "Upload your video and add a title",
            canContinue: false,
            status: undefined,
        }, {
            title: "Thumbnail",
            description: "Choose a thumbnail for your video",
            canContinue: false,
            status: undefined,
        }, {
            title: "Audience",
            description: "Choose which tiers can access this video and its reach",
            canContinue: false,
            status: undefined,
        },
        {
            title: "Publish",
            description: "Publish your video",
            canContinue: false,
            status: undefined,
        }
    ];

    function tiersChanged(e: CustomEvent<TierSelection>) {
        tiers = e.detail;
    }

    function editTeaser() {
        openModal(VideoPreviewEditorModal, {
            video,
            teaser,
            teaserUrl: teaser.url,
            onUploaded: (teaserUrl) => {
                teaser.url = teaserUrl;
                wideDistribution = !!teaserUrl;
            }
        });
    }
</script>

<UserProfile user={$user} bind:authorUrl />

<ItemEditShell
    bind:step
    bind:steps
    on:publish={publish}
>
    <div class:hidden={step !== 0}>
        <Page1
            bind:video={video}
            bind:videoFile={videoFile}
            bind:canContinue={steps[0].canContinue}
            bind:pendingStatus={steps[0].status}
        />
    </div>
    <div class:hidden={step !== 1}>
        <Page2
            {videoFile}
            bind:video
            bind:canContinue={steps[1].canContinue}
            bind:pendingStatus={steps[1].status}
            bind:step
        />
    </div>

    <div class:hidden={step !== 2}>
        <DistributionPage
            type="video"
            {tiers}
            bind:nonSubscribersPreview
            bind:wideDistribution
            bind:canContinue={steps[2].canContinue}
            on:changed={tiersChanged}
            on:editPreview={editTeaser}
        />
    </div>

    {#if step === 3}
        <div transition:fade={{duration: 1000}}>
            <PublishingStep
                {publishing}
                title={video.title??"Untitled"}
                {shareUrl}
            />
        </div>
    {/if}
</ItemEditShell>

{#if $debugMode}
    <pre>{JSON.stringify(video.rawEvent(), null, 4)}</pre>
{/if}

{#if $debugMode && teaser}
    <pre>{JSON.stringify(teaser.rawEvent(), null, 4)}</pre>
{/if}
