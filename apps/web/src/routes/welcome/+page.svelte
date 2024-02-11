<script lang="ts">
	import CreatorOnboardingActions from '$components/PageSidebar/CreatorOnboardingActions.svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader, pageSidebar } from '$stores/layout';

	$pageHeader = {
		title: "Welcome",
	};

	$pageSidebar = null;
</script>

<MainWrapper
	marginClass="max-w-3xl mx-auto"
>
    <CreatorOnboardingActions forceView={true} />
</MainWrapper>