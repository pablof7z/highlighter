<script lang="ts">
	import currentUser from '$stores/currentUser.js';
    import { createEventDispatcher } from 'svelte';
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
</script>

<LoadingScreen ready={!!$currentUser}>
	<ProfileEditPage {forceSave} on:saved={() => goto('/welcome/tiers')} />
</LoadingScreen>
