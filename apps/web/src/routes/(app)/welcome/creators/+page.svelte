<script lang="ts">
    import LogoSmall from '$icons/LogoSmall.svelte';
	import Step3 from './Step3.svelte';
	import Step4 from './Step4.svelte';
	import { ArrowRight } from 'phosphor-svelte';
	import { CheckCircle, ThumbsUp } from 'phosphor-svelte';
	import { slide } from 'svelte/transition';
    import TierList from '$components/Creator/TierList.svelte';

    let step = 0;

    function next() {
        step++;
    }
</script>

{#if step === 0}
    <div class="step-wrapper" transition:slide>
        <div class="flex flex-col gap-2 justify-center items-start text-left">
            <div class="flex flex-col gap-2">
                <div class="flex flex-row items-center gap-4">
                    <h1 class="font-semibold flex-grow">
                        <span class="opacity-90">
                            Let your readers
                        </span>
                        <div class="flex flex-row gap-4">
                            <span class="font-black">highlight</span>

                            <span class="opacity-90">
                                you
                            </span>
                        </div>
                    </h1>
                </div>

                <h3 class="text-neutral-500 text-xl leading-loose max-sm:text-left">
                    Highlighter lets you focus on your work while your readers
                    give you the exposure you deserve.
                </h3>

                <ul class="flex flex-col gap-3 my-10">
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
                        Get paid for your work directly, with no middlemen
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
    <div class="step-wrapper" transition:slide>
        <div class="flex flex-col gap-2 justify-center items-start text-left">
            <div class="flex flex-col">
                <h2 class="font-semibold">
                    Tiers
                </h2>

                <h3 class="text-neutral-500 text-xl leading-loose max-sm:text-left">
                    Create support tiers with different perks for your subscribers to choose from.
                </h3>

                <div class="text-white">
                    Don't stress, you can always edit this later
                </div>
            </div>
        </div>

        <div class="flex flex-col gap-8">
            <TierList
                on:saved={next}
                redirectOnSave={false}
                usePresetButton={true}
            >
                <div slot="saveButton" class="flex flex-row">
                    Next
                    <ArrowRight class="w-6 h-6 ml-2" />
                </div>
            </TierList>
        </div>
    </div>
{:else if step === 2}
    <div class="step-wrapper" transition:slide>
        <div class="flex flex-col gap-2 justify-center items-start text-left">
            <div class="flex flex-col">
                <h2 class="font-semibold">
                    Profile
                </h2>

                <h3 class="text-2xl leading-loose max-sm:text-left">
                    Create an eye-catching profile to attract your readers.
                </h3>
            </div>
        </div>

        <Step3 on:saved={next} />
    </div>
{:else if step === 3}
    <div class="step-wrapper" transition:slide>
        <Step4 />
    </div>
{/if}

<style>
    h1 {
        @apply text-5xl leading-tight;
    }

    h2 {
        @apply text-5xl text-white;
    }

    h3 {
        @apply text-xl;
    }

    .form-field {
        @apply flex flex-col gap-2;
    }

    .form-field label {
        @apply text-xl text-white;
    }

    .step-wrapper {
        @apply flex flex-col gap-10 max-sm:px-4 max-w-prose mx-auto py-10;
    }
</style>