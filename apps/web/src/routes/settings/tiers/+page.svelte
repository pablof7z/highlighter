<script lang="ts">
	import TierList from "$components/Creator/TierList.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import currentUser from "$stores/currentUser";
	import { pageHeader } from "$stores/layout";
	import { startUserView } from '$stores/user-view';

    let saving = false;
    let forceSave = false;

	$pageHeader = {
		title: "Tiers",
		left: {
			label: "Back",
			url: "/welcome",
		},
		right: {
			label: saving ? "loading" : "Save",
			fn: () => {forceSave = true}
		}
	};

	$: $pageHeader!.right!.label = saving ? "loading" : "Save";

	$: if (forceSave && saving) {
		forceSave = false;
	}
</script>

<TierList
	redirectOnSave="/settings"
	usePresetButton={false}
	bind:saving
	bind:forceSave
/>