<script lang="ts">
    import { NDKKind, NDKPrivateKeySigner, type Hexpubkey, type NostrEvent, NDKRelaySet, NDKNostrRpc, NDKUser, type NDKRpcResponse, NDKNip46Signer } from "@nostr-dev-kit/ndk";
    import Input from "$components/Forms/Input.svelte";
	import { bunkerNDK, ndk, user } from "@kind0/ui-common";
    import createDebug from "debug";
	import { closeModal } from "svelte-modals";
	import NsecBunkerProviderSelect from "$components/Forms/NsecBunkerProviderSelect.svelte";
	import type { NsecBunkerProvider } from "../../app";
	import { slide } from "svelte/transition";

    let email: string;
    let username: string;
    let nsecBunker: NsecBunkerProvider = {
        pubkey: "4f7bd9c066a7b21d750b4e8dbf4440ef1e80c64864341550200b8481d530c5ce",
        domain: "getfaaans.com"
    };
    let creating: boolean;
    let usernameTaken = false;

    async function signup() {
        creating = true;
        // See if this username resolves to an existing NIP-05
        const domain = nsecBunker.domain;
        const nip05 = await NDKUser.fromNip05([ username, domain ].join("@"));

        if (nip05) {
            usernameTaken = true;
            return;
        }

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
        const recipient = $ndk.getUser({ pubkey: nsecBunker.pubkey });
        const debug = createDebug("signup");
        const rpc = new NDKNostrRpc($bunkerNDK, localSigner, debug);
        const authPayload = { email, username, domain };

        rpc.subscribe({ kinds: [24133 as number], "#p": [localKeyPubkey] });
        let popup: Window | null = null;
        rpc.on("authUrl", (url: string) => {
            popup = window.open(url, "_blank", "width=350,height=450");
            let checkPopup = setInterval(() => {
            if (popup?.closed) {
                clearInterval(checkPopup);
                creating = false;
            }
        }, 500); // Check every 500ms
        });

        rpc.sendRequest(
            nsecBunker.pubkey,
            "create_account",
            [JSON.stringify(authPayload)],
            24134,
            async (res: NDKRpcResponse) => {
                const remotePubkey = JSON.parse(res.result)[0];
                const remoteSigner = new NDKNip46Signer($bunkerNDK, remotePubkey, localSigner);
                const u = await remoteSigner.blockUntilReady();
                console.log({u});
                $user = u;
                $ndk.signer = remoteSigner;
                localStorage.setItem("nostr-key-method", 'nip46');
                localStorage.setItem('nostr-target-npub', $user.npub);
                popup.close();
                closeModal();
            }
        );

        // const remoteSigner = new NDKNip46Signer($bunkerNDK, localKey, debug);

        // Open iFrame

    }

    let usernameHasFocus = false;
    let recoveryHasFocus = false;

    async function checkUsername() {
        const domain = nsecBunker?.domain;
        if (username.length === 0 || !domain) return;
        const nip05 = await NDKUser.fromNip05([ username, domain ].join("@"));

        if (nip05) {
            usernameTaken = true;
        } else {
            usernameTaken = false;
        }
    }
</script>

<div class="text-center text-black text-lg font-medium leading-normal">Create an account</div>

<div class="flex flex-col gap-4">
    <div class="flex flex-col gap-1">
        <div class="font-semibold">
            Choose your username
        </div>
        <div class="relative">
            <Input
                tabindex={1}
                bind:value={username}
                type="text"
                autocomplete="off"
                placeholder="Username"
                autofocus={true}
                on:focus={() => usernameHasFocus = true}
                on:blur={() => {usernameHasFocus = false; checkUsername(); }}
            />
            <div class="absolute border-0 inset-y-1 right-0.5 flex items-center text-sm text-gray-500">
                <NsecBunkerProviderSelect bind:value={nsecBunker} />
            </div>
        </div>
        <div
            class="text-xs opacity-50 transition-all duration-300"
        >
            Don't stress about it; you can change your username any time
        </div>

        {#if usernameTaken}
        <div class="alert alert-warning text-sm font-medium" transition:slide>
            This username is already taken
        </div>
    {/if}
    </div>

    <div class="flex flex-col gap-1">
        <div class="font-semibold">
            Email
            <span class="font-normal opacity-50">(optional)</span>
        </div>
        <Input
            tabindex={2}
            color="white"
            type="email"
            placeholder="Recovery email"
            bind:value={email}
            on:focus={() => recoveryHasFocus = true}
            on:blur={() => recoveryHasFocus = false}
        />
        <div
            class="text-xs opacity-50 transition-all duration-300"
        >
            We only use this to recover your account if you lose your password
        </div>
    </div>
    <button class="button button-primary transition duration-300 flex flex-col gap-1" on:click={signup} disabled={username?.length === 0 || !nsecBunker?.pubkey || creating} transition:slide>
        {#if !creating}
            Create account
            {#if username?.length > 0 && nsecBunker.domain}
                <span class="text-sm font-light">

                    {username}@{nsecBunker.domain}
                </span>
            {:else}
            {/if}
        {:else}
            <div class="loading loading-sm"></div>
        {/if}
    </button>
</div>
