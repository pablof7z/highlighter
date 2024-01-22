<script lang="ts">
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import PageTitle from '$components/Page/PageTitle.svelte';
	import PageTitleWithSearch from '$components/Page/PageTitleWithSearch.svelte';
    import SectionHeader from '$components/Page/SectionHeader.svelte';

    const marginClass ="w-full";
</script>

<PageTitleWithSearch
    title="Discover"
    {marginClass}
/>

<MainWrapper {marginClass}>
    <slot />
</MainWrapper>
