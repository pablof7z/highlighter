<script lang="ts">
	import MainWrapper from '$components/Page/MainWrapper.svelte';
    import SectionHeader from '$components/Page/SectionHeader.svelte';
</script>

<MainWrapper>
    <SectionHeader title="Discover" />
    <slot />
</MainWrapper>
