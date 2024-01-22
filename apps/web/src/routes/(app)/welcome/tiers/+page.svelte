<script>
	import { goto } from "$app/navigation";
	import TierList from "$components/Creator/TierList.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import MobileHeader from "$components/Page/MobileHeader.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { pageHeader } from "$stores/layout";
	import { ArrowRight } from "phosphor-svelte";

    let saving = false;
    let forceSave = false;

	$pageHeader = {
		title: "Tiers",
		leftLabel: "Back",
		leftUrl: "/welcome",
		rightLabel: saving ? "loading" : "Save",
		rightFn: () => {forceSave = true}
	};

	$: $pageHeader.rightLabel = saving ? "loading" : "Save";

	$: if (forceSave && saving) {
		forceSave = false;
	}
</script>

<MainWrapper
    marginClass="max-w-3xl"
>
    <TierList
        redirectOnSave={false}
        usePresetButton={true}
        bind:saving
        bind:forceSave
        on:saved={() => goto("/welcome")}
	/>
</MainWrapper>