<script lang="ts">
    import type { NDKVideo } from '@nostr-dev-kit/ndk';
	import { debugMode } from "$stores/session";
	import { Info, LockSimple } from "phosphor-svelte";
	import SelectTier from '../SelectTier.svelte';
	import VideoUploader from '../VideoUploader.svelte';
	import Checkbox from '../Checkbox.svelte';

    export let video: NDKVideo;
    export let teaser: NDKVideo;
    export let teaserUrl: string | undefined = undefined;
    export let tiers: Record<string, boolean>;
    export let canContinue: boolean;
    export let nonSubscribersPreview = true;
    export let wideDistribution: boolean;

    let hasFree: boolean;
    $: hasFree = !!tiers["Free"];

    let useTrailer = !!video.tagValue("preview");

    $: canContinue = tiers && Object.keys(tiers).filter(tier => tiers[tier]).length > 0;

    function teaserUploaded(e: CustomEvent<{url: string}>): void {
        teaserUrl = e.detail.url;
        wideDistribution = true;
	}

    $: if (useTrailer === false) {
        teaserUrl = undefined;
    }

    $: if (!hasFree && (!nonSubscribersPreview || !teaserUrl)) {
        wideDistribution = false;
    }
</script>

<div class="flex flex-col gap-8">
    <div class="flex flex-col">
        <div class="flex flex-col gap-1">
            <div class="font-semibold text-white text-xl">Content Tier</div>
            <div class="text-white/50 font-thin">
                Select the tiers that will have access to this video.
            </div>
        </div>
        <SelectTier bind:tiers show={true} skipTitle={true} />
    </div>

    <div class="flex flex-col gap-4" class:hidden={tiers["Free"]}>
        <div class="divider"></div>
        <Checkbox bind:value={nonSubscribersPreview}>
            Non-subscribers preview version
            <div slot="description">
                {#if nonSubscribersPreview}
                    <div class="text-neutral-500">
                        Non-subscribers will see a preview of this article.
                    </div>
                {:else}
                    <div class="text-neutral-500">
                        Non-subscribers will not know this article exists.
                    </div>
                {/if}
            </div>
        </Checkbox>

        <div class="transition-all duration-300 flex flex-col gap-6" class:hidden={!nonSubscribersPreview}>
            <div class="alert alert-neutral mb-2">
                <Info size="24" class="mr-2 text-info" />
                <div class="flex flex-col gap-2">
                    <div class="text-base font-medium">Teaser Video</div>
                    <div class="text-sm text-neutral-500">
                        This video will be shown to non-subscribers to entice them to become your faaans.
                    </div>
                </div>
                <div>
                    <button class="button" on:click={() => useTrailer = !useTrailer}>
                        Upload Trailer
                    </button>
                </div>
            </div>

            <div class="flex flex-col gap-1">
                <div class="font-semibold text-white text-xl">Teaser Preview</div>
                <div class="text-white/50 font-thin">
                    This is how your teaser will look like to non-subscribers.
                </div>
            </div>
            <div class="flex flex-row gap-6">
                {#if !useTrailer}
                    <div class="relative mx-auto max-w-lg flex-none">
                        <!-- svelte-ignore a11y-missing-attribute -->
                        <img class="w-full rounded-[20px] object-cover object-top" src={video.thumbnail} />
                        <div class="absolute top-0 left-0 w-full h-full bg-black/50 flex flex-col items-center justify-center">
                            <button class="button px-4 py-3 scale-75">
                                <LockSimple class="w-6 h-6 ml-2" />
                                Become a fan to unlock
                            </button>
                        </div>
                    </div>
                {:else}
                    <VideoUploader
                        wrapperClass="min-h-[12rem]"
                        bind:video={teaser}
                        bind:videoUrl={teaserUrl}
                        on:uploaded={teaserUploaded}
                    />
                {/if}
            </div>
        </div>
    </div>

    {#if hasFree || (nonSubscribersPreview && teaserUrl)}
        <Checkbox bind:value={wideDistribution} button={wideDistribution}>
            Distribute {#if !hasFree}preview version{/if} widely
            <div slot="description">
                {#if wideDistribution}
                    <div class="text-neutral-500">
                        This {!hasFree ? "preview" : "video"} will be published to video feeds beyond your Faaans page.
                        <br>
                        This helps you reach more readers!
                    </div>
                {:else}
                    <div class="text-neutral-500">
                        This {!hasFree ? "preview" : "video"} will only be visible on your Faaans page, not throughout other video sites.
                    </div>
                {/if}
            </div>
        </Checkbox>
    {/if}
</div>