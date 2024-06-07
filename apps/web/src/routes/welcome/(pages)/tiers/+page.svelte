<script lang="ts">
	import { goto } from "$app/navigation";
	import TierList from "$components/Creator/TierList.svelte";
	import { pageHeader } from "$stores/layout";

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
	redirectOnSave={false}
	usePresetButton={true}
	bind:saving
	bind:forceSave
	on:saved={() => goto("/welcome")}
/>