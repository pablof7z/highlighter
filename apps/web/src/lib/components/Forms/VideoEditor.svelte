<script lang="ts">
	import { fade } from 'svelte/transition';
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKVideo, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { CaretLeft, CaretRight, Image, Images, Link, Upload, X } from "phosphor-svelte";
	import { debugMode } from "$stores/session";
	import Page1 from "./VideoEditorPage/Page1.svelte";
	import Page2 from "./VideoEditorPage/Page2.svelte";
	import Page3 from "./VideoEditorPage/Page3.svelte";
	import { getDefaultRelaySet } from '$utils/ndk';
	import { publishToTiers } from '$actions/publishToTiers';
	import { goto } from '$app/navigation';

    export let video: NDKVideo = new NDKVideo($ndk, {
        content: "",
    } as NostrEvent);
    export let teaser: NDKVideo = new NDKVideo($ndk);
    export let tiers: Record<string, boolean>;

    let videoFile: File | undefined;
    let nonSubscribersPreview: boolean;

    let step = 0;

    function prev() {
        step--;
    }

    function next() {
        if (step === 2) {
            if (statusToShow) return;

            return publish();
        } else {
            step++;
        }
    }

    async function publish() {
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

        console.log(`video`, video.rawEvent())
        console.log(`teaser`, teaser.rawEvent())

        await publishToTiers(video, tiers, {
            relaySet,
            ndk: $ndk,
            teaserEvent: teaser
        });

        video = video;
        teaser = teaser;

        goto(`/dashboard`);
        newToasterMessage("Video published", "success");
    }

    let pendingStatus: string[] = [];
    let canContinue = [false, false, false];
    let showPrevButton = false;

    $: showPrevButton = step > 0;

    let statusToShow: string | undefined = undefined;

    $: teaser.content = video.content;

    $: statusToShow = pendingStatus.find(status => status !== undefined);
</script>

<div class="flex flex-col border-none border-neutral-800 rounded-xl gap-6">
    <div class:hidden={step !== 0}>
        <Page1
            bind:video={video}
            bind:videoFile={videoFile}
            bind:canContinue={canContinue[0]}
            bind:pendingStatus={pendingStatus[0]}
            bind:step
        />
    </div>
    <div class:hidden={step !== 1}>
        <Page2
            {videoFile}
            bind:video
            bind:canContinue={canContinue[1]}
            bind:pendingStatus={pendingStatus[1]}
            bind:step
        />
    </div>

    <div class:hidden={step !== 2}>
        <Page3
            bind:video
            bind:teaser
            bind:tiers
            bind:canContinue={canContinue[2]}
            bind:pendingStatus={pendingStatus[2]}
            bind:step
            bind:nonSubscribersPreview
        />
    </div>

    <div class="w-full flex flex-row justify-between">
        <div>
            <button class="button px-6 py-2.5" on:click={prev} class:hidden={!showPrevButton}>
                <CaretLeft size="18" />
                Previous
            </button>
        </div>

        {#if statusToShow}
            <div class="flex flex-row gap-2 items-center" transition:fade>
                {statusToShow}
                <span class="loading loading-sm loading-dots"></span>
            </div>
        {/if}

        <button class="button px-6 py-2.5 transition-all duration-100" on:click={next} disabled={!canContinue[step]}>
            {#if step === 2}
                Publish
            {:else}
                Next
            {/if}
            <CaretRight size="18" />
        </button>
    </div>
</div>

{#if $debugMode}
    <pre>{JSON.stringify(video.rawEvent(), null, 4)}</pre>
{/if}

{#if $debugMode && teaser}
    <pre>{JSON.stringify(teaser.rawEvent(), null, 4)}</pre>
{/if}
