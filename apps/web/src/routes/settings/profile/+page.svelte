<script lang="ts">
	import Settings from '$components/PageSidebar/Settings.svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import ProfileEditPage from "$components/User/ProfileEditPage.svelte";
	import { pageHeader, pageSidebar } from "$stores/layout";
	import { onDestroy } from "svelte";
	import { goto } from '$app/navigation';

    $pageSidebar = { component: Settings, props: {} }
    onDestroy(() => { $pageSidebar = null; })

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

<MainWrapper>
    <ProfileEditPage
        bind:saving bind:forceSave
        on:saved={() => {
            goto("/settings")
        }}
    />
</MainWrapper>