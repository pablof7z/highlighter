<script lang="ts">
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type Hexpubkey, NDKUser } from "@nostr-dev-kit/ndk";
	import type { NsecBunkerProvider } from "../../../app";

    export let value: NsecBunkerProvider = { pubkey: "", domain: ""};
    let selection = value.pubkey;

    $: if (selection !== value.pubkey) {
        value = { pubkey: selection, domain: nsecBunkerProviders[selection] };
    }

    const allNsecBunkerProviders = $ndk.storeSubscribe(
        { kinds: [NDKKind.AppHandler], "#k": [NDKKind.NostrConnect.toString()] },
        { closeOnEose: true, subId: 'nsec-bunker-providers' }
    )

    let nsecBunkerProviders: Record<Hexpubkey, string> = {};

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
                    nsecBunkerProviders = nsecBunkerProviders;
                }
            })
        } catch (e) {
            console.error(e);
        }
    }
</script>

<select bind:value={selection} class="border-0 flex items-center text-sm text-gray-500 focus:ring-0 focus:outline-none pr-7">
    {#each Object.entries(nsecBunkerProviders) as [pubkey, domain]}
        <option value={pubkey}>@{domain}</option>
    {/each}
</select>