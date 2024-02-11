<script lang="ts">
	import Settings from '$components/PageSidebar/Settings.svelte';
	import Checkbox from "$components/Forms/Checkbox.svelte";
    import { pageHeader, pageSidebar } from "$stores/layout";
	import { ndk } from "@kind0/ui-common";
	import { onDestroy } from "svelte";
	import MainWrapper from '$components/Page/MainWrapper.svelte';

    $pageSidebar = { component: Settings, props: {} }
    onDestroy(() => { $pageSidebar = null; })

    $pageHeader = {
        title: "Privacy",
        leftLabel: "Back",
        leftUrl: "/settings",
    };

    let announceClient = !!$ndk.clientNip89;
</script>

<MainWrapper marginClass="max-w-3xl">
    <Checkbox
        bind:value={announceClient}
    >
        Enable client identity
        <span class="text-sm" slot="description">
            If this is turned on, public notes you create will have a "client" tag added. This helps with troubleshooting, and allows other people to find out about Highlighter.
        </span>
    </Checkbox>
</MainWrapper>

<style lang="postcss">
    h1 {
        @apply text-2xl font-semibold text-white;
        @apply mb-4;
    }

    h2 {
        @apply text-lg font-semibold;
        @apply mb-2;
    }

    section {
        @apply mb-6;
    }
</style>