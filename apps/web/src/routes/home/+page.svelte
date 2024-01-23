<script lang="ts">
    import MainWrapper from "$components/Page/MainWrapper.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import PageTitleWithSearch from "$components/Page/PageTitleWithSearch.svelte";
	import CreatorOnboardingActions from '$components/PageSidebar/CreatorOnboardingActions.svelte';
	import { pageHeader } from "$stores/layout";
	import { onMount } from "svelte";

    $pageHeader = {
        title: "Home",
        searchBar: true
    }
</script>

<MainWrapper>
    <div class="flex flex-col gap-10 w-full sm:my-10">
        <CreatorOnboardingActions />
    </div>
</MainWrapper>

    <style>
        .bg {
            background: radial-gradient(100.21% 187.14% at 0% 0.15%, #BD9488 0%, #7092A0 100%) /* warning: gradient uses a rotation that is not supported by CSS and may not behave as expected */;
        }
    </style>

