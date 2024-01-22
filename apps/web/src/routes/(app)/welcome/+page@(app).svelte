<script lang="ts">
	import CreatorOnboardingActions from '$components/PageSidebar/CreatorOnboardingActions.svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader } from "$stores/layout";

	$pageHeader = {
		title: "Home"
	}
</script>

<MainWrapper
	marginClass="max-w-3xl mx-auto"
>
    <CreatorOnboardingActions />
</MainWrapper>