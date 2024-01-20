<script lang="ts">
    import MainWrapper from "$components/Page/MainWrapper.svelte";
	import SectionHeader from "$components/Page/SectionHeader.svelte";
	import CreatorOnboardingActions from '$components/PageSidebar/CreatorOnboardingActions.svelte';
</script>

<MainWrapper>
    <SectionHeader title="Home" />

    <div class="flex flex-col max-w-3xl mx-auto gap-10 w-full my-10">
        <CreatorOnboardingActions />
    </div>
</MainWrapper>

    <style>
        .bg {
            background: radial-gradient(100.21% 187.14% at 0% 0.15%, #BD9488 0%, #7092A0 100%) /* warning: gradient uses a rotation that is not supported by CSS and may not behave as expected */;
        }
    </style>

