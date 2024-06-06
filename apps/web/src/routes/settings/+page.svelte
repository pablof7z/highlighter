<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
    import { page } from "$app/stores";
    import { pageHeader } from "$stores/layout";
	import { NDKEvent } from '@nostr-dev-kit/ndk';
	import { ndk } from '$stores/ndk';
    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageHeader = {
        title: "Settings",
        left: {
            label: "Back",
            url: "/",
        },
        right: {
        }
    };
</script>

<svelte:head>
    <title>Settings</title>
</svelte:head>

<SettingsMenu />
