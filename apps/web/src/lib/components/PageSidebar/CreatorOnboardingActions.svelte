<script lang="ts">
	import { CaretRight, Check } from "phosphor-svelte";
    import User from "./OnboardingCheckingIcons/User.svelte";
    import Tiers from "./OnboardingCheckingIcons/Tiers.svelte";
	import Post from "./OnboardingCheckingIcons/Post.svelte";
	import { openModal } from '$utils/modal';
	import NewItemModal from "$modals/NewItemModal.svelte";
	import { getUserSubscriptionTiersStore, getContent } from "$stores/user-view";
	import { onMount } from "svelte";
	import type { NDKEvent, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import type { Readable } from "svelte/motion";

    export let sidebarView = false;
    export let forceView = sidebarView;

    let currentTiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    let content: Readable<NDKEvent[]> | undefined = undefined;

    let hasTiers = false;
    let hasContent = false;
    let hasProfileBanner  = true;

    onMount(() => {
        currentTiers = getUserSubscriptionTiersStore();
        content = getContent();
    })

    $: hasTiers = !!currentTiers && !!$currentTiers?.length;
    $: hasContent = !!content && !!$content?.length;

    let hiddenOrCompleted: boolean | undefined = undefined;

    onMount(() => {
        hiddenOrCompleted = !!localStorage.getItem("creator-onboarding-done");
    })

    function hide() {
        hiddenOrCompleted = true;
        localStorage.setItem("creator-onboarding-done", "true");
    }
</script>

{#if hiddenOrCompleted === false || forceView}
    <div
        class="flex flex-col gap-5"
        class:py-6={sidebarView}
        class:px-4={sidebarView}
    >
        <div class="flex flex-row justify-between items-end">
            <h2 class="text-2xl text-white">What's next?</h2>
            {#if !sidebarView}
                <button class="btn btn-base-300 text-sm" on:click={hide}>
                    Hide
                </button>
            {/if}
        </div>

        <div class="settings-like-section-title -mb-4">
            First steps
        </div>

        <a href="/welcome/profile">
            <div>
                <span>
                    <User />
                    Complete your profile
                </span>

                <!-- <span>
                    {#if !sidebarView}
                        <span class="bg-clip-text text-transparent bg-gradient-to-r from-[#BD9488] to-[#7092A0]">
                            2 of 4 Completed
                        </span>
                    {/if}
                </span> -->
            </div>

            <span class="caret">
                <CaretRight class="w-6 h-6" />
            </span>
        </a>

        <a href="/welcome/tiers">
            <div>
                <span>
                    {#if !hasTiers}
                        <Tiers />
                    {:else}
                        <Check class="text-success" weight="duotone" />
                    {/if}
                    <div class="flex flex-col items-start">
                        <span>Set up your membership tiers</span>
                        <div class="text-xs text-neutral-500">
                            <span>
                                Manage membership prices and perks
                            </span>
                        </div>
                    </div>
                </span>
            </div>

            <span class="caret">
                <CaretRight class="w-6 h-6" />
            </span>
        </a>

        <button on:click={() => openModal(NewItemModal)}>
            <div>
                <span>
                    {#if !hasContent}
                        <Post />
                    {:else}
                        <Check class="text-success" weight="duotone" />
                    {/if}
                    <span>Publish your first post</span>
                </span>
            </div>

            <span class="caret">
                <CaretRight class="w-6 h-6" />
            </span>
        </button>

        <div class="divider"></div>

        <div class="mt-5 -mb-4 settings-like-section-title opacity-30">
            Subscribers
        </div>

        <a href="#" class="relative opacity-30 pointer-events-none cursor-not-allowed">
            <div class="coming-soon">
                <span class="coming-soon">
                    Coming soon
                </span>
            </div>
            <div>
                <span>
                    <User />
                    <div class="flex flex-col items-start">
                        <span>Import</span>
                        <div class="text-xs text-neutral-500">
                            <span>
                                Import your list of email subscribers
                            </span>
                        </div>
                    </div>
                </span>
            </div>

            <span class="caret">
                <CaretRight class="w-6 h-6" />
            </span>
        </a>

        <a href="#" class="relative opacity-30 pointer-events-none cursor-not-allowed">
            <div class="coming-soon">
                <span class="coming-soon">
                    Coming soon
                </span>
            </div>
            <div>
                <span>
                    <User />
                    <div class="flex flex-col items-start">
                        <span>Get your first subscribers</span>
                        <div class="text-xs text-neutral-500">
                            <span>
                                How do you bootstrap an audience?
                            </span>
                        </div>
                    </div>
                </span>
            </div>

            <span class="caret">
                <CaretRight class="w-6 h-6" />
            </span>
        </a>

        <a href="/welcome/referrals" class="relative opacity-30 pointer-events-none cursor-not-allowed">
            <div class="coming-soon">
                <span class="coming-soon">
                    Coming soon
                </span>
            </div>
            <div>
                <span>
                    <Post />
                    <div class="flex flex-col items-start">
                        <span>Set up a referral program</span>
                        <div class="text-xs text-neutral-500">
                            <span>
                                Incentivize your subscribers to share your content
                            </span>
                    </div>
                </span>
            </div>

            <span class="caret">
                <CaretRight class="w-6 h-6" />
            </span>
        </a>

        <div class="mt-5 -mb-4 settings-like-section-title opacity-30">
            Content Dissemination
        </div>

        <a href="#" class="relative opacity-30 pointer-events-none cursor-not-allowed">
            <div class="coming-soon">
                <span class="coming-soon">
                    Coming soon
                </span>
            </div>
            <div>
                <span>
                    <User />
                    <div class="flex flex-col items-start">
                        <span>How do subscribers amplify me?</span>
                        <div class="text-xs text-neutral-500">
                            <span>
                                Learn how your subscribers disseminate your content by naturally interacting with it
                            </span>
                        </div>
                    </div>
                </span>
            </div>

            <span class="caret">
                <CaretRight class="w-6 h-6" />
            </span>
        </a>
    </div>
{/if}

<style>
    a, button {
        @apply flex flex-row justify-between border border-base-300 p-4 rounded-box bg-base-200
        transition-all duration-300 ease-in-out;
    }

    a:hover, button:hover {
        @apply bg-base-300/60;
    }

    a > div > span:first-child, button > div > span:first-child {
        @apply font-normal flex flex-row items-center gap-4 text-neutral-300 flex-grow;
    }

    a > div > span:last-child, button > div > span:last-child {
        @apply flex flex-row items-center gap-4;
    }

    span.caret {
        @apply flex flex-row items-center gap-4;
    }
</style>