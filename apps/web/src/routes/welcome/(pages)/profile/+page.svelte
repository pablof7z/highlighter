<script lang="ts">
	import currentUser from '$stores/currentUser.js';
    import { createEventDispatcher } from 'svelte';
	import { pageHeader } from '$stores/layout.js';
	import ProfileEditPage from '$components/User/ProfileEditPage.svelte';
	import LoadingScreen from '$components/LoadingScreen.svelte';
	import { goto } from "$app/navigation";

    const dispatch = createEventDispatcher();

    let saving = false;

    async function saveClicked() {
        forceSave = true;
        dispatch('saved');
    }

    let forceSave = false;

	$pageHeader = {
		title: "Profile",
		left: {
			label: "Back",
			url: "/welcome",
		},
		right: {
			label: saving ? "loading" : "Save",
			fn: saveClicked
		}
	};
</script>

<LoadingScreen ready={!!$currentUser}>
	<ProfileEditPage {forceSave} on:saved={() => goto('/welcome/tiers')} />
</LoadingScreen>

<style lang="postcss">
    h3 {
        @apply text-3xl text-foreground font-semibold;
    }
</style>