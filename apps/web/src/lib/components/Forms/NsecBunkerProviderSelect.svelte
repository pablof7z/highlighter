<script lang="ts">
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type Hexpubkey } from "@nostr-dev-kit/ndk";
	import type { NsecBunkerProvider } from "../../../app";
	import NsecBunkerProviderItem from "./NsecBunkerProviderItem.svelte";
    import { createEventDispatcher } from "svelte";

    export let value: NsecBunkerProvider = { pubkey: "", domain: ""};
    export let username: string | undefined;

    const dispatch = createEventDispatcher();

    let selection = value.pubkey;

    export let allNsecBunkerProviders = $ndk.storeSubscribe(
        { kinds: [NDKKind.AppHandler], "#k": [NDKKind.NostrConnect.toString()] },
        { closeOnEose: true, subId: 'nsec-bunker-providers' }
    )

    function onClick(e: CustomEvent<{pubkey: Hexpubkey, domain: string}>) {
        const { pubkey, domain } = e.detail;
        selection = pubkey;
        value = { pubkey, domain }
        dispatch("click")
    }
</script>

<div class:hidden={!open}>
    <ul class="bg-black/50 border border-white/10 flex-nowrap rounded-box p-0 overflow-y-auto h-fit">
        {#each $allNsecBunkerProviders as provider (provider.id)}
            <NsecBunkerProviderItem
                {provider}
                {username}
                selected={provider.pubkey === selection}
                on:click={onClick}
            />
        {/each}
    </ul>
</div>
