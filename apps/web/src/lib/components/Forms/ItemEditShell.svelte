<script lang="ts">
	import { slide } from "svelte/transition";
    import { createEventDispatcher, onMount } from "svelte";
	import { CaretRight, DownloadSimple, PaperPlaneTilt } from "phosphor-svelte";
	import { goto } from "$app/navigation";
	import { pageHeader, type PageHeader } from "$stores/layout";
	import MainWrapper from "$components/Page/MainWrapper.svelte";

    const dispatch = createEventDispatcher();

    type Step = {
        title: string;
        description: string;
        canContinue?: boolean;
        status?: string;
    }

    export let steps: Step[];
    export let step: number;

    function next() {
        if (steps[step].canContinue === false) return;
        if (step === steps.length - 1) return goto("/dashboard");

        step++;

        if (step === steps.length - 1) {
            dispatch("publish");
        }
    }

	function back() {
        if (step > 0 && step < steps.length - 1) step--;
        if (step === 0) dispatch("draft");
	}

    let statusToShow: string | undefined = undefined;
    $: statusToShow = steps.find(step => step.status !== undefined)?.status;

    let main: HTMLElement;
    let footer: HTMLElement;

    let nextIsPublish = false;

    $: nextIsPublish = step === steps.length - 2;

    setInterval(() => {
        // make the top margin of the main element equal to the height of the footer if we are on mobile
        const isMobile = window.matchMedia("(max-width: 640px)").matches;
        if (main && footer) {
            if (!isMobile) {
                main.style.marginBottom = footer.clientHeight + "px";
                main.style.marginTop = "0";
            } else {
                main.style.marginTop = footer.clientHeight + "px";
                main.style.marginBottom = "0";
            }
        } else if (main) {
            main.style.marginTop = "0";
            main.style.marginBottom = "0";
        }
    }, 50);

    $: {
        const header: PageHeader = {
            title: steps[step].title,
            rightLabel: nextIsPublish ? "Publish" : "Next",
            rightFn: next
        }

        if (step > 0) {
            header.leftLabel = "Back";
            header.leftFn = back;
        } else {
            header.leftIcon = DownloadSimple;
            header.leftLabel = "Draft";
            header.leftFn = () => dispatch("draft");
        }

        $pageHeader = header;
    }
</script>

<MainWrapper mobilePadded={false} class="pb-24" bind:el={main}>
    <slot />
</MainWrapper>

<footer class="max-sm:bg-base-200 max-sm:bg-opacity-80 backdrop-blur-[50px]" bind:this={footer}>
    <div class="mx-auto max-w-3xl sm:py-8 max-sm:mobile-nav max-sm:fixed max-sm:w-full max-sm:h-20 max-sm:px-3 z-50">
        {#if statusToShow}
            <div class="text-center pb-4 inline-flex gap-4 items-end justify-center w-full" transition:slide>
                {statusToShow}
                <span class="loading loading-sm loading-dots"></span>
            </div>
        {/if}

        <div class="flex flex-col sm:flex-row justify-between items-center">
            <progress
                class="progress progress-accent w-full transition-all duration-1000 sm:hidden mb-2 sm:mb-4"
                value={(Math.max(step*10, 1))}
                max={steps.length*10}></progress>

            <ul class="steps steps-horizontal w-full max-sm:hidden md:w-2/3">
                {#each steps as s, i}
                    <li
                        class="step max-sm:text-xs"
                        class:step-white={i <= step}
                        data-content={s.status ? "●" : undefined}
                    >{s.title}</li>
                {/each}
            </ul>

            <div class="
                grid grid-flow-col
                gap-6
                max-sm:w-full justify-between
            ">
                <button
                    class="px-4 whitespace-nowrap button button-black sm:py-3"
                    class:opacity-0={step === steps.length - 1}
                    on:click={back}
                >
                    {#if step === 0}
                        Save Draft
                    {:else}
                        Back
                    {/if}
                </button>

                <button
                    class="
                        sm:button whitespace-nowrap sm:py-2
                        max-sm:text-accent2 h-full
                    "
                    on:click={next}
                    class:px-4={nextIsPublish}
                    disabled={steps[step].canContinue === false}
                >
                    {#if nextIsPublish}
                        Publish
                        <PaperPlaneTilt class="w-7 h-7 mr-1 inline" />
                    {:else if step === steps.length - 1}
                        Go to dashboard
                    {:else}
                        Next<span class="max-sm:hidden font-normal"> {steps[step + 1].title}</span>
                        <CaretRight class="w-5 h-5 sm:hidden inline" />
                    {/if}
                </button>
            </div>
        </div>
    </div>
    <div class="sm:hidden h-20"></div>
</footer>

<style lang="postcss">
    main {
        @apply flex flex-col gap-10;
        @apply max-sm:mt-24;
    }

    footer {
        @apply fixed w-full left-0 z-50 right-0;
        @apply max-sm:top-0 sm:bottom-0;
        @apply max-sm:bg-base-200/50 sm:border-t border-base-300;
        @apply max-sm:hidden;
    }

    .steps .step-white + .step-white:before {
  /* white background color */
  --c: 0 0% 100%;
  --tw-bg-opacity: 1;
  background-color: hsl(var(--c) / var(--tw-bg-opacity));
}
.steps .step-white:after {
  /* white background color */
  --c: 0 0% 100%;
  /* black content color */
  --cc: 0 0% 0%;
  --tw-bg-opacity: 1;
  background-color: hsl(var(--c) / var(--tw-bg-opacity));
  --tw-text-opacity: 1;
  font-weight: 800;
  color: hsl(var(--cc, var(--nc)) / var(--tw-text-opacity));
}

</style>