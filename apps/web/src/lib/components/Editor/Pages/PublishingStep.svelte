<script lang="ts">
	import { fade } from 'svelte/transition';
    import { onMount } from "svelte";
	import { CaretRight, Share } from 'phosphor-svelte';

    export let title: string | undefined = "undefined";
    export let shareUrl: string | undefined = "undefined";

    let LottiePlayer: any;

    onMount(async () => {
        const module = await import("@lottiefiles/svelte-lottie-player");
        LottiePlayer = module.LottiePlayer;
    });

    function share() {
        navigator.share({
            title,
            text: "Check out my new post on Highlighter!",
            url: shareUrl
        });
    }

    let inputEl: HTMLInputElement | undefined;
    let publishAt: Date | undefined;
</script>

{#if LottiePlayer}
    <div class="flex flex-col items-center gap-10">
        <div class="max-w-lg mx-auto w-full">
            <LottiePlayer
                src="/images/done.json"
                autoplay={true}
                loop={false}
                controls={false}
                renderer="svg"
                background="transparent"
                speed={0.5}
            />
        </div>

        <a href="/dashboard" class="flex flex-row items-center gap-2 text-white text-center font-['InterDisplay'] text-2xl font-bold" transition:fade={{duration: 3000}}>
            Go to dashboard
            <CaretRight class="w-6 h-6" />
        </a>

        {#if navigator.share}
            <button class="button text-lg px-4" transition:fade={{ delay: 4000, duration: 1000}} on:click={share}>
                <Share class="w-6 h-6" />
                Share
            </button>
        {/if}
    </div>
{/if}