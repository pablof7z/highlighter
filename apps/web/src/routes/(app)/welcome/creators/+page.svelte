<script lang="ts">
	import Step3 from './Step3.svelte';
	import { ArrowRight } from 'phosphor-svelte';
	import { CheckCircle, ThumbsUp } from 'phosphor-svelte';
    import OnboardingChecklist from '$components/Creator/OnboardingChecklist.svelte';
	import { slide } from 'svelte/transition';
    import TierList from '$components/Creator/TierList.svelte';

    let step = 2;

    function next() {
        step++;
    }
</script>

{#if step === 0}
    <div class="flex flex-col gap-10 max-sm:px-4 max-w-prose mx-auto">
        <div class="flex flex-col justify-center items-start max-sm:text-center text-left">

            <div class="flex flex-col gap-10 py-10" transition:slide>
                <h1 class="font-semibold text-center">
                    <span class="opacity-90">
                        Let your
                        <span>readers</span>
                    </span>
                    <mark class="font-black">highlight</mark>
                    <span class="opacity-90">
                        you
                    </span>
                </h1>

                <h2 class="text-2xl leading-loose max-sm:text-left">
                    Highlighter lets you focus on your work while your readers
                    give you the exposure you deserve.
                </h2>

                <ul class="flex flex-col gap-3">
                    <li class="flex flex-row items-start gap-2">
                        <CheckCircle class="w-6 h-6 text-info" weight="duotone" />
                        Your readers organically disseminate your content
                    </li>
                    <li class="flex flex-row items-start gap-2">
                        <CheckCircle class="w-6 h-6 text-info" weight="duotone" />
                        Maximize your reach without even thinking about ads
                    </li>
                    <li class="flex flex-row items-start gap-2">
                        <CheckCircle class="w-6 h-6 text-info" weight="duotone" />
                        Get paid for your work
                    </li>
                </ul>
            </div>

            <button class="button px-10 py-4" on:click={next}>
                Let's get started
                <ArrowRight class="w-6 h-6 ml-2" />
            </button>
        </div>
    </div>
{:else if step === 1}
    <div class="flex flex-col gap-10 max-sm:px-4 max-w-prose mx-auto">
        <div class="flex flex-col justify-center items-start max-sm:text-center text-left">
            <div class="flex flex-col" transition:slide>
                <h1 class="font-semibold">
                    <div class="opacity-100">
                        Tiers
                    </div>
                </h1>

                <h2 class="text-2xl leading-loose max-sm:text-left">
                    Create support tiers with different perks for your subscribers to choose from.
                </h2>

                <div role="alert" class="alert shadow-lg">
                    <ThumbsUp class="w-6 h-6 mr-2 text-info" />
                    <div>
                        <h3>Don't stress, you can always edit this later</h3>
                    </div>
                    <button class="button button-black">Skip using a preset</button>
                </div>
            </div>
        </div>

        <div class="flex flex-col gap-8">
            <TierList
                on:saved={next}
                redirectOnSave={false}
            >
                <div slot="saveButton" class="flex flex-row">
                    Next
                    <ArrowRight class="w-6 h-6 ml-2" />
                </div>
            </TierList>
        </div>
    </div>
{:else if step === 2}
    <div class="flex flex-col gap-10 max-sm:px-4 max-w-prose mx-auto">
        <div class="flex flex-col justify-center items-start max-sm:text-center text-left">
            <div class="flex flex-col" transition:slide>
                <h1 class="font-semibold">
                    <div class="opacity-100">
                        Profile
                    </div>
                </h1>

                <h2 class="text-2xl leading-loose max-sm:text-left">
                    Create an eye-catching profile to attract your readers.
                </h2>
            </div>
        </div>

        <Step3 />
    </div>
{/if}

<style>
    h1 {
        @apply text-[clamp(2rem,6vw,4.2rem)];
    }

    .form-field {
        @apply flex flex-col gap-2;
    }

    .form-field label {
        @apply text-xl text-white;
    }
</style>