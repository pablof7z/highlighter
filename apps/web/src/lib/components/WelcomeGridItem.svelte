<script lang="ts">
	import { browser } from '$app/environment';
    import { user } from "@kind0/ui-common";
	import SignupModal from '$modals/SignupModal.svelte';
	import { seenOnboardingPromptGridItem } from "$stores/settings";
	import { CaretRight, X } from "phosphor-svelte";
	import { onMount } from "svelte";
	import { openModal } from '$utils/modal';
	import { userTiers } from '$stores/session';
	import { slide } from 'svelte/transition';

    let display: boolean | undefined;

    onMount(async () => {
        setTimeout(() => {
            if (!$user) {
                display = $seenOnboardingPromptGridItem !== true;
            } else {
                display = $userTiers.length === 0;
            }
        }, 1000);
    })

    $: if (browser && $seenOnboardingPromptGridItem === true) {
        display = false;
    }

    $: if ($userTiers.length > 0) display = false;

    function dismiss() {
        $seenOnboardingPromptGridItem = true;
        display = false;
    }

    function getStarted() {
        const mode = !$user ? 'signup' : 'welcome';
        openModal(SignupModal, { mode })
    }
</script>

{#if display}
<div class="w-full bg-gradient p-[1px] flex transition-all duration-300 mb-2" transition:slide>
    <div class="w-full flex flex-row items-center bg-base-100/30 p-3 lg:p-1 text-base gap-10 justify-center">
        <div class="flex flex-col">
            <h1 class="text-lg lg:text-base font-bold">
                Are you a content creator?
            </h1>

            <div class="text-sm max-md:hidden">
                Set up your creator profile and start earning from your audience.
            </div>
        </div>

        <div class="flex flex-row gap-4">
            <button class="button w-full h-fit whitespace-nowrap" on:click={getStarted}>
                Get Started
                <CaretRight class="w-5 h-5 inline" />
            </button>

            <button class="text-base" on:click={dismiss}>
                <X class="w-5 h-5" />
            </button>
        </div>
    </div>
</div>
{/if}