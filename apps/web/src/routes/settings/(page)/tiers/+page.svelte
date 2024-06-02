<script lang="ts">
	import { goto, pushState, replaceState } from "$app/navigation";
	import TierList from "$components/Creator/TierList.svelte";
	import { pageHeader } from "$stores/layout";

    let saving = false;
    let forceSave = false;

	console.log("setting tiers page");
	
	pushState("/settings/tiers", {
		main: true,
	});

	$pageHeader = {
		title: "Tiers",
		left: {
			label: "Back",
			fn: () => {
				goto('/settings');
			}
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