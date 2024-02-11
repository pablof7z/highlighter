<script lang="ts">
	import { browser } from '$app/environment';
    import { ndk, user } from "@kind0/ui-common";
	import SignupModal from '$modals/SignupModal.svelte';
	import { seenOnboardingPromptGridItem } from "$stores/settings";
	import { CaretRight } from "phosphor-svelte";
	import { onMount } from "svelte";
	import { openModal } from "svelte-modals";
	import { userTiers } from '$stores/session';
	import { slide } from 'svelte/transition';

    let display: boolean | undefined;

    onMount(async () => {
        if (!$user) {
            display = $seenOnboardingPromptGridItem !== true;
        } else {
            display = $userTiers.length === 0;
        }
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
<div class="w-fit sm:rounded-box bg-gradient p-[1px] flex max-lg:col-span-2 lg:row-span-2 transition-all duration-300" transition:slide>
    <div class="bg-base-100/30 w-fit sm:rounded-box p-6 text-lg flex flex-col gap-4">
        <h1 class="text-2xl font-medium">
            Are you a creator?
        </h1>

        <div class="grow">
            <p>
                Set up your creator profile and start publishing your work on Nostr
                and getting paid for your work.
            </p>
        </div>

        <div class="flex flex-col-reverse lg:flex-row gap-4">

            <button class="text-base" on:click={dismiss}>
                Dismiss
            </button>

            <button class="button w-full py-2.5 px-6 whitespace-nowrap" on:click={getStarted}>
                Get Started
                <CaretRight class="w-5 h-5 inline" />
            </button>
        </div>
    </div>
</div>
{/if}