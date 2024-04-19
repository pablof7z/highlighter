<script lang="ts">
	import HomeNavigation from "$components/PageElements/Navigation/HomeNavigation.svelte";
	import ThreeColumn from "$components/Layouts/ThreeColumn.svelte";
</script>

<ThreeColumn>
    <div slot="left">
        <div class="lg:py-4 pr-4">
            <HomeNavigation />
        </div>
    </div>

    <div class="md:hidden sticky top-14 z-50 bg-black/90">
        <div class="border-t border-base-300 mt-4 mb-2">
            <HomeNavigation />
        </div>
    </div>

    <slot />
</ThreeColumn>
