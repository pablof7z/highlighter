<script lang="ts">
    import { getDefaultRelaySet } from "$utils/ndk";
	import { ndk } from "@kind0/ui-common";
	import { RelayList } from "@nostr-dev-kit/ndk-svelte-components";

    const creatorRelays = getDefaultRelaySet();
</script>

<h1>Network</h1>

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