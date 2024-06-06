<script lang="ts">
	import { CaretRight, Check, CirclesFour, HandWaving, PaperPlaneTilt, SquareLogo, StarFour, User } from "phosphor-svelte";
    import Tiers from "./OnboardingCheckingIcons/Tiers.svelte";
	import Post from "./OnboardingCheckingIcons/Post.svelte";
	import { openModal } from '$utils/modal';
	import NewItemModal from "$modals/NewItemModal.svelte";
	import { getUserSubscriptionTiersStore, getContent } from "$stores/user-view";
	import { onMount } from "svelte";
	import type { NDKEvent, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import type { Readable } from "svelte/motion";
	import { Button } from "$components/ui/button";
	import { Block } from "konsta/svelte";
	import { appMobileView } from "$stores/app";

    export let sidebarView = false;
    export let forceView = sidebarView;

    let currentTiers: Readable<NDKSubscriptionTier[]> | undefined = undefined;
    let content: Readable<NDKEvent[]> | undefined = undefined;

    let hasTiers = false;
    let hasContent = false;
    let hasProfileBanner = true;
    let hasIntroduction = false;

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
        class="
            flex flex-col gap-5 max-sm:px-
            {$appMobileView ? "text-sm z-10 relative pl-4-safe pr-4-safe my-8" : ""}
        "
    >
        <div class="flex flex-col sm:grid lg:grid-cols-3 gap-4">
            <Button class="flex flex-col sm:h-32 h-auto items-center justify-center text-primary-foreground normal-case max-sm:p-4" href="/welcome/profile">
                <User class="w-24 h-24 opacity-20 text-primary-foreground" />
                <span class="text-2xl font-medium text-primary-foreground">
                    Personalize
                </span>
                <span class="whitespace-normal text-center text-sm text-primary-foreground">
                    Make your account, yours...
                </span>
            </Button>

            <Button variant={hasTiers ? "secondary" : "default"} class="flex flex-col items-center h-auto justify-start normal-case max-sm:p-4" href="/welcome/tiers">
                <SquareLogo class="w-24 h-24 opacity-20 text-primary-foreground" />
                <span class="text-xl font-medium text-primary-foreground">
                    Subscription Tiers
                </span>

                <span class="whitespace-normal text-center text-sm text-primary-foreground">Create support options for your most ravvid supporters?</span>
            </Button>

            <Button variant={hasContent ? "secondary" : "default"} class="flex flex-col items-center h-auto justify-start normal-case" on:click={() => openModal(NewItemModal)}>
                <PaperPlaneTilt class="w-24 h-24 opacity-20 text-primary-foreground" />
                <span class="text-xl font-medium text-primary-foreground">
                    Publish
                </span>

                <span class="whitespace-normal text-center text-sm text-primary-foreground">
                    Publish your first post
                </span>
            </Button>

            <Button variant={hasIntroduction ? "secondary" : "default"} class="col-span-3 flex flex-col sm:flex-row gap-4 items-center h-auto justify-start normal-case max-sm:p-4" href="/welcome/tiers">
                <HandWaving class="w-12 h-12 max-sm:w-24 max-sm:h-24 opacity-20 text-primary-foreground" />
                <span class="text-xl font-medium text-primary-foreground">
                    Say Hi!
                </span>

                <span class="whitespace-normal text-center text-sm text-primary-foreground">
                    Introduce yourself so others know what you make and care about!
                </span>
            </Button>
        </div>

        <div class="divider"></div>

        <div class="mt-5 -mb-4 settings-like-section-title opacity-30">
            Subscribers
        </div>

        <a href="#" class="opacity-30 pointer-events-none cursor-not-allowed">
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
        @apply flex flex-row justify-between border border-border p-4 rounded bg-foreground/10
        transition-all duration-300 ease-in-out;
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