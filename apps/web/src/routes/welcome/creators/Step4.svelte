<!-- <script lang="ts">
	import { PaperPlaneTilt } from 'phosphor-svelte';
	import NewItemModal from '$modals/NewItemModal.svelte';
	import { CaretRight, DownloadSimple, Question, UserList } from 'phosphor-svelte';
	import { onMount } from "svelte";
	import { openModal } from '$utils/modal';

    let LottiePlayer: any;

    onMount(async () => {
        const module = await import("@lottiefiles/svelte-lottie-player");
        LottiePlayer = module.LottiePlayer;
    });
</script>

<div class="group flex flex-col gap-10">
    <div class="flex flex-col gap-3">
        <h1 class="text-5xl font-bold">
            You're all set!
        </h1>
        <h2 class="text-xl pb-4">
            You're now ready to start monetizing your content while your subscribers enjoy your content
            and organically disseminate it among their networks.
        </h2>
        <h2 class="text-xl text-white">
            The future of content publishing and monetization is here.
        </h2>
    </div>

    <div class="section">
        <div class="section-title">Publishing</div>

        <div class="section-links">
            <button class="opt default" on:click={() => openModal(NewItemModal)}>
                <span class="icon">
                    <PaperPlaneTilt class="w-full h-full" />
                </span>
                <div>
                    <span class="title">Create your first publication</span>
                    <span class="description">Create, publish. Rinse & repeat.</span>
                </div>

                <CaretRight class="w-6 h-6" />
            </button>
            <a class="opt" href="#">
                <span class="icon">
                    <DownloadSimple class="w-full h-full" />
                </span>
                <div>
                    <span class="title">Import</span>
                    <span class="description">
                        Import your content from legacy platforms
                    </span>
                </div>

                <span class="flex flex-row items-center flex-nowrap gap-0">
                    <span class="badge badge-sm opacity-50">Coming soon</span>
                    <CaretRight class="w-6 h-6" />
                </span>
            </a>
        </div>
    </div>

    <div class="section">
        <div class="section-title">
            Subscribers
        </div>

    </div>

    <div class="section">
        <div class="section-title">
            Content Dissemination
        </div>

    </div>
</div>

<style lang="postcss">
    .section {
        @apply flex flex-col gap-1;
    }

    .section-title {
        @apply text-xl font-semibold;
    }

    .section-links {
        @apply border rounded-box border-base-300;
        @apply divide-y divide-base-300 flex flex-col;
    }

    .opt {
        @apply flex flex-row items-center p-4;
        @apply transition-all duration-100;
        @apply relative;
    }

    .opt::before, .opt.default::before {
        @apply bg-gradient-to-r from-accent/30 to-accent/20;
        @apply transition-all duration-100;
        @apply absolute top-0 left-0 w-full h-full opacity-0 pointer-events-none;
        @apply opacity-0;
        content: '';
    }

    .opt:hover::before, .opt.default::before {
        @apply opacity-100;
    }

    .opt:first-child::before { @apply rounded-t-box; }
    .opt:last-child::before { @apply rounded-b-box; }

    .opt:not(:first-child) {
        @apply pt-4;
    }

    .opt:not(:last-child) {
        @apply pb-4;
    }

    .opt span.icon {
        @apply flex-none w-7 h-7 opacity-50 transition-all duration-100;
        @apply mr-4;
    }

    .opt:hover span.icon, .opt.default span.icon {
        @apply opacity-100 text-white;
    }

    .opt > div {
        @apply flex flex-col gap-0 flex-grow items-start;
    }

    .opt .title {
        @apply text-lg font-medium text-white lg:brightness-90 lg:text-opacity-80 transition-all duration-100;
    }

    .opt:hover .title, .opt.default .title {
        @apply brightness-100 text-opacity-100;
    }

    .opt .description {
        @apply text-sm text-base-content opacity-50 transition-all duration-100;
    }

    .opt:hover .description, .opt.default .description {
        @apply opacity-80;
    }
</style> -->