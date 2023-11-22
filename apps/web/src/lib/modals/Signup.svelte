<script lang="ts">
    import { NDKKind, NDKPrivateKeySigner, type Hexpubkey, type NostrEvent, NDKRelaySet, NDKNostrRpc, NDKUser, type NDKRpcResponse, NDKNip46Signer } from "@nostr-dev-kit/ndk";
    import Input from "$components/Forms/Input.svelte";
	import { derived } from "svelte/store";
	import { bunkerNDK, ndk, user } from "@kind0/ui-common";
    import createDebug from "debug";
	import { closeModal } from "svelte-modals";

    let email: string = '';
    let username: string = '';
    let provider: string = "4f7bd9c066a7b21d750b4e8dbf4440ef1e80c64864341550200b8481d530c5ce" ;

    export let iframeUrl: string | undefined;

    const allNsecBunkerProviders = $ndk.storeSubscribe(
        { kinds: [NDKKind.AppHandler], "#k": [NDKKind.NostrConnect.toString()] },
        { closeOnEose: true, subId: 'nsec-bunker-providers' }
    )

    const nsecBunkerProviders = derived(allNsecBunkerProviders, ($allNsecBunkerProviders) => {
        const providers: Record<Hexpubkey, string> = {};
        const events = $allNsecBunkerProviders?.filter((handler) => handler.tagValue("k") === NDKKind.NostrConnect.toString())

        if (events) {
            events.forEach((event) => {
                try {
                    const profile = JSON.parse(event.content);
                    const nip05 = profile?.nip05;
                    const [ username, domain ] = nip05?.split("@") ?? [];

                    if (username === '_' && domain) {
                        // should verify that the NIP-05 resolves to this pubkey
                        providers[event.pubkey] = domain;
                    } else {
                        console.log(`invalid nip05: ${nip05}`);
                    }
                } catch (e) {
                    console.error(e);
                }
            });
        }

        return providers;
    });

    async function signup() {
        // See if this username resolves to an existing NIP-05
        const domain = $nsecBunkerProviders[provider];
        // const nip05 = await NDKUser.fromNip05([ username, domain ].join("@"));

        // if (nip05) {
        //     alert('already exists, login instead');
        //     return;
        // }

        await $bunkerNDK.connect(2500);

        // Create local key
        const existingPrivateKey = localStorage.getItem('nostr-nsecbunker-key');
        let localSigner: NDKPrivateKeySigner | undefined;

        if (existingPrivateKey) {
            try {
                localSigner = new NDKPrivateKeySigner(existingPrivateKey);
            } catch (e) {
                console.error(e);
            }
        }

        if (!localSigner) {
            localSigner = NDKPrivateKeySigner.generate();
            localStorage.setItem("nostr-nsecbunker-key", localSigner.privateKey!);
        }

        const localKeyPubkey = (await localSigner.user()).pubkey;

        // Generate event
        const recipient = $ndk.getUser({ pubkey: provider });
        const debug = createDebug("signup");
        const rpc = new NDKNostrRpc($bunkerNDK, localSigner, debug);
        const authPayload = { email, username, domain };

        rpc.subscribe({ kinds: [24133 as number], "#p": [localKeyPubkey] });
        rpc.on("authUrl", (url: string) => {
            window.open(url, "_blank", "width=350,height=450");
        });

        rpc.sendRequest(
            provider,
            "create_account",
            [JSON.stringify(authPayload)],
            24134,
            async (res: NDKRpcResponse) => {
                const remotePubkey = JSON.parse(res.result)[0];
                const remoteSigner = new NDKNip46Signer($bunkerNDK, remotePubkey, localSigner);
                const u = await remoteSigner.blockUntilReady();
                console.log({u});
                $user = u;
                localStorage.setItem("nostr-key-method", 'nip46');
                localStorage.setItem('nostr-target-npub', $user.npub);
                closeModal();
            }
        );

        // const remoteSigner = new NDKNip46Signer($bunkerNDK, localKey, debug);

        // Open iFrame

    }
</script>

<p class="text-center text-lg mt-2">Create an account</p>

{#if !iframeUrl}
    <div class="flex flex-col gap-4 mt-6">
        <Input type="email" placeholder="Recovery email" autofocus={true} bind:value={email} />
        <div class="flex flex-col gap-2">
            <div class="relative">
                <Input bind:value={username} type="text" autocomplete="off" placeholder="Username" />
                <div class="absolute border-0 inset-y-1 right-4 flex items-center text-sm text-gray-500">
                    <select bind:value={provider} class="border-0 flex items-center text-sm text-gray-500">
                        {#each Object.entries($nsecBunkerProviders) as [pubkey, domain]}
                            <option value={pubkey}>@{domain}</option>
                        {/each}
                    </select>
                </div>
            </div>
            <p class="text-gray-500 text-xs">You can change your username any time</p>
        </div>
        <div class="mb-6 hidden">
            <input type="password" placeholder="Password" class="w-full px-4 py-3 bg-white rounded-full shadow border border-neutral-200 justify-start items-center gap-2 inline-flex" />
        </div>
        <button class="button-primary" on:click={signup} disabled={!provider}>
            Create account
        </button>
    </div>
{:else}

{/if}