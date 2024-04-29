<script lang="ts">
	import HomeNavigation from "$components/PageElements/Navigation/HomeNavigation.svelte";
	import ThreeColumn from "$components/Layouts/ThreeColumn.svelte";
	import { onDestroy } from "svelte";

    let mobileNavContainer: HTMLDivElement;

    function handleScroll() {
        let leftMargin = window.scrollY * 0.9;

        if (leftMargin > 48) leftMargin = 48;
        if (leftMargin < 0) leftMargin = 0;

        mobileNavContainer.style.marginLeft = `${leftMargin}px`;
    }

    document.addEventListener("scroll", handleScroll);

    onDestroy(() => {
        document.removeEventListener("scroll", handleScroll);
    });
</script>

<ThreeColumn>
    <div slot="left">
        <div class="lg:py-4 pr-4">
            <HomeNavigation />
        </div>
    </div>

    <div class="md:hidden sticky top-0 z-50 bg-black/90" bind:this={mobileNavContainer}>
        <div class="border-t border-base-300 mb-2">
            <HomeNavigation />
        </div>
    </div>

    <slot />
</ThreeColumn>
