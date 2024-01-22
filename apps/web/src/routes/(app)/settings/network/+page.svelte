<script lang="ts">
	import Settings from '$components/PageSidebar/Settings.svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
    import { pageHeader, pageSidebar } from "$stores/layout";
    import { getDefaultRelaySet } from "$utils/ndk";
	import { ndk } from "@kind0/ui-common";
	import { RelayList } from "@nostr-dev-kit/ndk-svelte-components";
	import { onDestroy } from 'svelte';

    $pageSidebar = { component: Settings, props: {} }
    onDestroy(() => { $pageSidebar = null; })

    $pageHeader = {
        title: "Network Settings",
        leftLabel: "Back",
        leftUrl: "/settings",
    };

    const creatorRelays = getDefaultRelaySet();
</script>

<MainWrapper>
    <section>
        <h2>Creator Relays</h2>

        <ul class="menu w-fit">
            {#each creatorRelays.relays as relay}
                <li class="px-3">
                    {relay.url}
                </li>
            {/each}
        </ul>
    </section>

    <h2>Relays</h2>

    <RelayList ndk={$ndk} />
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