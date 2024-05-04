<script lang="ts">
	import ProfileEditPage from "$components/User/ProfileEditPage.svelte";
	import { pageHeader, pageSidebar } from "$stores/layout";
	import { onDestroy } from "svelte";
	import { goto } from '$app/navigation';

    let forceSave = false;
    let saving = false;

    $pageHeader = {
        title: "Profile",
        left: {
            label: "Back",
            url: "/settings",
        },
        right: {
            label: "Save",
            fn: () => forceSave = true
        }
    };

    $: if (saving) {
        $pageHeader!.right!.label = "loading";
    } else {
        $pageHeader!.right!.label = "Save";
    }
</script>

    <ProfileEditPage
        bind:saving bind:forceSave
        on:saved={() => {
            goto("/settings")
        }}
    />