<script lang="ts">
	import Settings from '$components/PageSidebar/Settings.svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import ProfileEditPage from "$components/User/ProfileEditPage.svelte";
	import { pageHeader, pageSidebar } from "$stores/layout";
	import { onDestroy } from "svelte";

    $pageSidebar = { component: Settings, props: {} }
    onDestroy(() => { $pageSidebar = null; })

    $pageHeader = {
        title: "Profile",
        left: {
            label: "Back",
            url: "/settings",
        }
    };
</script>

<MainWrapper>
    <ProfileEditPage />
</MainWrapper>