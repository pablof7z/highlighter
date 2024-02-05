<script lang="ts">
	import Settings from '$components/PageSidebar/Settings.svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
    import { pageHeader, pageSidebar } from "$stores/layout";
    import { getDefaultRelaySet } from "$utils/ndk";
	import { ndk } from "@kind0/ui-common";
	import { RelayList } from "@nostr-dev-kit/ndk-svelte-components";
	import { onDestroy } from 'svelte';
	import GlassyInput from '$components/Forms/GlassyInput.svelte';

    $pageSidebar = { component: Settings, props: {} }
    onDestroy(() => { $pageSidebar = null; })

    $pageHeader = {
        title: "Network Settings",
        left: {
            label: "Back",
            url: "/settings",
        }
    };

    const creatorRelays = getDefaultRelaySet();
</script>

<MainWrapper>
    <section class="settings">
        <div class="title">
            Relays
        </div>

        <div class="field">
            <div class="title">
                Creator Relays
            </div>

                {#each creatorRelays.relays as relay}
                    <GlassyInput
                        type="text"
                        readonly={true}
                        value={relay.url}
                        placeholder="Relay URL"
                        class="text-sm"
                    />
                    <div class="text-xs text-neutral-500">
                        This URL can't be changed yet.
                    </div>
                {/each}
        </div>

        <div class="field">
            <div class="ttile">
                Connections
                <RelayList ndk={$ndk} />
            </div>
        </div>
    </section>
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