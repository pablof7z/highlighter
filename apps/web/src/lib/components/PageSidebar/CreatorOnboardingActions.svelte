<script lang="ts">
	import { CaretRight } from "phosphor-svelte";
    import User from "./OnboardingCheckingIcons/User.svelte";
    import Tiers from "./OnboardingCheckingIcons/Tiers.svelte";
	import Post from "./OnboardingCheckingIcons/Post.svelte";
	import { openModal } from "svelte-modals";
	import NewItemModal from "$modals/NewItemModal.svelte";

    export let sidebarView = false;
</script>

<div
    class="flex flex-col gap-5"
    class:py-6={sidebarView}
    class:px-4={sidebarView}
>
    <div class="flex flex-row justify-between">
        <h2 class="text-2xl text-white">What's next?</h2>
    </div>

    <a href="/welcome/profile">
        <div>
            <span>
                <User />
                Complete your Profile
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
                <Tiers />
                <div class="flex flex-col items-start">
                    <span>Set up your membership tiers</span>
                    <div class="text-xs text-neutral-500">
                        <span>
                            Manage membership prices and perks
                        </span>
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
                <Post />
                <span>Publish your first post</span>
            </span>
        </div>

        <span class="caret">
            <CaretRight class="w-6 h-6" />
        </span>
    </button>

    <a href="/welcome/referrals">
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
</div>

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