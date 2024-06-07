<script lang="ts">
	import CreatorOnboardingActions from '$components/PageSidebar/CreatorOnboardingActions.svelte';
	import { pageHeader } from '$stores/layout';

	$pageHeader = {
		title: "Welcome",
	};
</script>

<CreatorOnboardingActions forceView={true} />