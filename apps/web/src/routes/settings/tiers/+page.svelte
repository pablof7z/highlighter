<script lang="ts">
	import Settings from '$components/PageSidebar/Settings.svelte';
	import { goto } from "$app/navigation";
	import TierList from "$components/Creator/TierList.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader, pageSidebar } from "$stores/layout";
	import { onMount } from 'svelte';
	import { startUserView } from '$stores/user-view';
	import { user } from '@kind0/ui-common';

    let saving = false;
    let forceSave = false;

	startUserView($user);

	$pageSidebar = { component: Settings, props: {} }

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

<MainWrapper>
    <TierList
        redirectOnSave="/settings"
        usePresetButton={false}
        bind:saving
        bind:forceSave
	/>
</MainWrapper>