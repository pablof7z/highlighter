<script lang="ts">
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type Hexpubkey, NDKUser, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import type { NsecBunkerProvider } from "../../../app";
	import { CaretDown } from "phosphor-svelte";

    export let value: NsecBunkerProvider = { pubkey: "", domain: ""};
    export let username: string | undefined;
    let selection = value.pubkey;

    // $: if (selection !== value.pubkey) {
    //     value = { pubkey: selection, domain: nsecBunkerProviders[selection] };
    // }

    export let onlyButton = false;

    export let allNsecBunkerProviders = $ndk.storeSubscribe(
        { kinds: [NDKKind.AppHandler], "#k": [NDKKind.NostrConnect.toString()] },
        { closeOnEose: true, subId: 'nsec-bunker-providers' }
    )

    let nsecBunkerProviders: Record<Hexpubkey, string> = {};
    let nsecBunkerProviderProfiles: Record<Hexpubkey, NDKUserProfile> = {};

    let validatedNsecbunkerProviders: Record<Hexpubkey, boolean> = {};

    async function validateNip05(pubkey: Hexpubkey, domain: string) {
        const user = await NDKUser.fromNip05(domain);

        console.log(`validateNip05`, domain, user?.pubkey, pubkey);

        return !!(user && user.pubkey === pubkey);
    }

    $: for (const provider of $allNsecBunkerProviders) {
        if (validatedNsecbunkerProviders[provider.pubkey] !== undefined) continue;
        validatedNsecbunkerProviders[provider.pubkey] = false;

        try {
            const profile = JSON.parse(provider.content);
            const nip05 = profile?.nip05;
            const [ username, domain ] = nip05?.split("@") ?? [];

            if (username !== "_") continue;
            validateNip05(provider.pubkey, domain).then(res => {
                validatedNsecbunkerProviders[provider.pubkey] = res;
                if (res) {
                    nsecBunkerProviders[provider.pubkey] = domain;
                    nsecBunkerProviderProfiles[provider.pubkey] = profile;
                    nsecBunkerProviders = nsecBunkerProviders;
                    nsecBunkerProviderProfiles = nsecBunkerProviderProfiles;
                }
            })
        } catch (e) {
            console.error(e);
        }
    }

    export let open = false;

    function toggleOpen() {
        open = !open;
    }
</script>

{#if !open}
    <button on:click={toggleOpen} class="border-0 flex items-center text-sm text-gray-500 focus:ring-0 focus:outline-none pr-2">
        {#if value?.domain}
            <span class="mr-2">@{value.domain}</span>
        {/if}
        <CaretDown class="w-5 h-5" />
    </button>
{:else if !onlyButton}
    <h1 class="mt-4 mb-2 text-lg !text-black text-center font-semibold">Choose a provider</h1>

    <ul class="menu !bg-transparent flex-nowrap border border-black/10 rounded-box p-0 overflow-y-auto h-fit">
        {#each Object.entries(nsecBunkerProviders) as [pubkey, domain]}
            <li class:active={value?.pubkey === pubkey} class="overflow-x-clip">
                <button
                    class="border-b rounded-b-none py-2 flex"
                    on:click={() => {
                        selection = pubkey;
                        value.pubkey = selection;
                        value.domain = nsecBunkerProviders[selection];
                        value = value;
                        toggleOpen();
                        // setTimeout(toggleOpen, 500);
                    }}
                >
                    <img src={nsecBunkerProviderProfiles[pubkey]?.picture??"https://cdn.satellite.earth/fb0e24f6cd8f581c8873e834656163dd497dce47dab8b878d73caf4aae3def89.png"} class="w-12 h-12 object-cover rounded flex-none" alt={domain} />
                    <div class="flex flex-col gap-1 whitespace-nowrap">
                        <span class="mr-2 font-bold">
                            {#if username}<span class="!font-normal opacity-40">{username}@</span>{/if}{domain}</span>
                        <div class="text-xs w-full truncate text-ellipsis opacity-50">{nsecBunkerProviderProfiles[pubkey].about ?? ""}</div>
                    </div>
                </button>
            </li>
        {/each}
    </ul>
{/if}

<style>
    li.active {
        @apply bg-accent/10;
    }
</style>