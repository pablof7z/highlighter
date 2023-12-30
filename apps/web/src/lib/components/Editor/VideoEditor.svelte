<script lang="ts">
	import PublishingStep from './Pages/PublishingStep.svelte';
	import { fade } from 'svelte/transition';
    import UserProfile from '$components/User/UserProfile.svelte';
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { NDKVideo, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { CaretLeft, CaretRight, Image, Images, Link, Upload, X } from "phosphor-svelte";
	import { debugMode } from "$stores/session";
    import DistributionPage from "./Pages/DistributionPage.svelte";
	import { getDefaultRelaySet } from '$utils/ndk';
	import { publishToTiers } from '$actions/publishToTiers';
    import Page1 from "./VideoEditorPage/Page1.svelte";
    import Page2 from "./VideoEditorPage/Page2.svelte";
	import { goto } from '$app/navigation';
	import ItemEditShell from '../Forms/ItemEditShell.svelte';
	import VideoEditorPreviewEditor from './VideoEditorPreviewEditor.svelte';

    export let video: NDKVideo = new NDKVideo($ndk, {
        content: "",
    } as NostrEvent);
    export let teaser: NDKVideo = new NDKVideo($ndk);
    export let tiers: Record<string, boolean>;

    let videoFile: File | undefined;
    let nonSubscribersPreview: boolean;

    let step = 0;

    let publishing = false;
    let shareUrl = "";

    async function publish() {
        publishing = true;
        const relaySet = getDefaultRelaySet();

        video.relay = Array.from(relaySet.relays)[0];

        // Don't create a preview video if all tiers are selected
        if (Object.keys(tiers).filter(tier => tiers[tier]).length === Object.values(tiers).length) {
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
        } catch (e) {
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
            bind:tiers
            bind:nonSubscribersPreview
            bind:wideDistribution
            bind:canContinue={steps[2].canContinue}
        >
            <div slot="previewEditor">
                <VideoEditorPreviewEditor
                    bind:video={video}
                    bind:teaser={teaser}
                    bind:wideDistribution
                />
            </div>
        </DistributionPage>
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
