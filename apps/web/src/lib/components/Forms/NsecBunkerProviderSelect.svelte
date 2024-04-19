<script lang="ts">
	import { bunkerNDK, ndk } from "@kind0/ui-common";
	import { NDKKind, type Hexpubkey, NDKEvent, NDKNostrRpc, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
	import type { NsecBunkerProvider } from "../../../app";
	import NsecBunkerProviderItem from "./NsecBunkerProviderItem.svelte";
    import { createEventDispatcher, onMount } from "svelte";
	import { derived } from "svelte/store";
    import createDebug from "debug";

    const debug = createDebug("HL:nsecbunker");

    export let value: NsecBunkerProvider = { pubkey: "", domain: ""};
    export let username: string | undefined;

    const dispatch = createEventDispatcher();

    let selection = value.pubkey;

    export let allNsecBunkerProviders = $ndk.storeSubscribe(
        { kinds: [NDKKind.AppHandler], "#k": [NDKKind.NostrConnect.toString()] },
        { closeOnEose: true, groupable: false }
    )

    const dedupedProviders = derived(allNsecBunkerProviders, $providers => {
        const pubkeys = new Set<Hexpubkey>();
        return $providers.filter((provider: NDKEvent) => {
            if (pubkeys.has(provider.pubkey)) return false;
            pubkeys.add(provider.pubkey);
            return true;
        })
    })

    let rpc: NDKNostrRpc;
    let pingRpcUser: NDKUser;

    onMount(async () => {
        await $bunkerNDK.connect(2500);
        const signer = NDKPrivateKeySigner.generate();
        pingRpcUser = await signer.user();
        rpc = new NDKNostrRpc($bunkerNDK, signer, debug);
        await rpc.subscribe({
            kinds: [24133 as number, 24134 as number],
            "#p": [pingRpcUser.pubkey],
        });
    })

    function onClick(e: CustomEvent<{pubkey: Hexpubkey, domain: string}>) {
        const { pubkey, domain } = e.detail;
        selection = pubkey;
        value = { pubkey, domain }
        dispatch("click")
    }
</script>

{#if rpc}
    <div class:hidden={!open}>
        <ul class="bg-black/50 border border-white/10 flex-nowrap rounded-box p-0 overflow-y-auto h-fit">
            {#each $dedupedProviders as provider (provider.id)}
                <NsecBunkerProviderItem
                    {provider}
                    {username}
                    {rpc}
                    {pingRpcUser}
                    selected={provider.pubkey === selection}
                    on:click={onClick}
                />
            {/each}
        </ul>
    </div>
{/if}