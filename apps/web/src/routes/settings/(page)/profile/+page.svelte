<script lang="ts">
	import ProfileEditPage from "$components/User/ProfileEditPage.svelte";
	import { layout } from "$stores/layout";
	import { goto } from '$app/navigation';

    let forceSave = false;
    let saving = false;

    $layout = {
        title: "Profile",
        back: {
            url: "/settings",
        }
    };
</script>

    <ProfileEditPage
        bind:saving bind:forceSave
        on:saved={() => {
            goto("/settings")
        }}
    />