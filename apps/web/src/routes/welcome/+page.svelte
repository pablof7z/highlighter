<script lang="ts">
	import CreatorOnboardingActions from '$components/PageSidebar/CreatorOnboardingActions.svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader } from '$stores/layout';

	$pageHeader = {
		title: "Welcome",
		left: {
			label: "Back",
			url: "/",
		}
	};
</script>

<MainWrapper
	marginClass="max-w-3xl mx-auto"
	class="lg:hidden"
>
    <CreatorOnboardingActions forceView={true} />
</MainWrapper>