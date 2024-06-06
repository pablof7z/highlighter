<script lang="ts">
	import { CaretLeft } from "phosphor-svelte";
	import { onMount } from "svelte";

    export let itemCount: number;

    let carousel: HTMLDivElement;
    let canScrollBack = false;
    let canScrollForward = false;

    function next() {
        const carouselWidth = carousel?.clientWidth;
        let scrollBy = carouselWidth * 0.5;
        if (carousel) {
            carousel.scrollBy({ left: scrollBy, behavior: "smooth" });
        }

        updateCanScroll();
    }

    function previous() {
        const carouselWidth = carousel?.clientWidth;
        let scrollBy = carouselWidth * 0.5;

        if (carousel) {
            carousel.scrollBy({ left: -scrollBy, behavior: "smooth" });
        }

        updateCanScroll();
    }

    function updateCanScroll() {
        canScrollForward = carousel?.scrollLeft + carousel?.clientWidth < carousel?.scrollWidth;
        canScrollBack = carousel?.scrollLeft > 0;
    }

    let scrollListener = false;

    onMount(() => {
        updateCanScroll();
    });

    $: if (itemCount) {
        updateCanScroll();
        if (!scrollListener) {
            carousel?.addEventListener("scroll", updateCanScroll);
            scrollListener = true;
        }
    }
</script>

<div class="relative">
    <div class="absolute flex transform top-1/2 left-0 z-20 -translate-y-1/2">
        <button on:click={previous} class="btn btn-circle btn-neutral transition-all duration-300" class:opacity-50={!canScrollBack} class:!opacity-0={!canScrollBack}>
            <CaretLeft class="w-12 h-12" />
        </button>
    </div>

    <div class="absolute flex transform top-1/2 right-0 z-20 -translate-y-1/2">
        <button on:click={next} class="btn btn-circle btn-neutral transition-all duration-300" class:opacity-50={!canScrollForward} class:!opacity-0={!canScrollForward}>
            <CaretLeft class="w-12 h-12 transform rotate-180" />
        </button>
    </div>

    <div class="carousel carousel-center rounded {$$props.class??""}" bind:this={carousel}>
        <slot />
    </div>
</div>