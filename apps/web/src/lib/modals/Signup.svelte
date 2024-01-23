<script lang="ts">
    import { NDKPrivateKeySigner, NDKUser, NDKNip46Signer, NDKEvent } from "@nostr-dev-kit/ndk";
    import Input from "$components/Forms/Input.svelte";
	import { bunkerNDK, ndk, user } from "@kind0/ui-common";
	import NsecBunkerProviderSelect from "$components/Forms/NsecBunkerProviderSelect.svelte";
	import type { NsecBunkerProvider } from "../../app";
	import { slide } from "svelte/transition";
	import { loginState } from '$stores/session';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { createEventDispatcher } from 'svelte';
	import GlassyInput from '$components/Forms/GlassyInput.svelte';

    const dispatch = createEventDispatcher();

    let email: string;
    let username: string = "";
    let nsecBunker: NsecBunkerProvider = {
        pubkey: "4f7bd9c066a7b21d750b4e8dbf4440ef1e80c64864341550200b8481d530c5ce",
        domain: "getfaaans.com"
    };
    let creating: boolean;
    let usernameTaken = false;
    let popupNotOpened = false;
    let authUrl: string;
    let allNsecBunkerProviders: NDKEventStore<NDKEvent>;

    function redirectToAuthUrlWithCallback(url: string) {
        const redirectUrl = new URL(url);
        const callbackPath = "/auth/callback";
        const currentUrl = new URL(window.location.href);
        const callbackUrl = new URL(callbackPath, currentUrl.origin);
        redirectUrl.searchParams.set("callbackUrl", callbackUrl.toString());
        localStorage.setItem("intended-url", window.location.href);
        window.location.href = redirectUrl.toString();
    }

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

        // Generate event
        const signer = new NDKNip46Signer($bunkerNDK, nsecBunker.pubkey, localSigner);
        let popup: Window | null = null;
        signer.rpc.on("authUrl", (url: string) => {
            popup = window.open(url, "_blank", "width=400,height=600");

            if (!popup) {
                popupNotOpened = true;
                redirectToAuthUrlWithCallback(url);
            }

            authUrl = url;
            let checkPopup = setInterval(() => {
                if (!popup) {
                    popupNotOpened = true;
                }
                if (popup?.closed) {
                    clearInterval(checkPopup);
                    creating = false;
                }
            }, 500); // Check every 500ms
        });

        try {
            const createdPubkey = await signer.createAccount(username, domain, email);
            const remoteSigner = new NDKNip46Signer($bunkerNDK, createdPubkey, localSigner);
            const u = await remoteSigner.blockUntilReady();
            $user = u;
            $ndk.signer = remoteSigner;
            localStorage.setItem("nostr-key-method", 'nip46');
            localStorage.setItem('nostr-target-npub', $user.npub);
            $loginState = "logged-in";
            popup?.close();
            dispatch("signed-up");
        } catch (e) {
            console.error(e);
            alert(e);
            creating = false;
        }
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

    let providerOpen = false;

    $: username = username.toLowerCase().replace(/[^a-z0-9_]/g, "");
</script>

<div class="relative">
    <div
        class="flex flex-col gap-4 transition-opacity duration-0"
        class:opacity-0={providerOpen}
    >
        <div class="field">
            <label>
                Choose a username
            </label>
            <div class="relative">
                <GlassyInput
                    tabindex={1}
                    bind:value={username}
                    type="text"
                    autocomplete="off"
                    placeholder="Username"
                    class="lowercase"
                    on:focus={() => usernameHasFocus = true}
                    on:blur={() => {usernameHasFocus = false; checkUsername(); }}
                />
                <div class="absolute border-0 inset-y-1 right-0.5 flex items-center text-sm text-gray-500">
                    <NsecBunkerProviderSelect {username} bind:allNsecBunkerProviders bind:value={nsecBunker} bind:open={providerOpen} onlyButton={true} />
                </div>
            </div>
            <div class="text-sm opacity-60 transition-all duration-300 -mt-1">
                <span class="text-white">Don't worry you can change it later.</span>
            </div>

            {#if usernameTaken}
            <div class="alert alert-error bg-error/20 text-white/80 py-3 my-3 text-sm font-medium" transition:slide>
                This username is already taken.
            </div>
        {/if}
        </div>

        <div class="flex flex-col gap-1 hidden">
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
        {#if !popupNotOpened}
            <button class="
                button button-primary transition duration-300 flex flex-col
                py-4 font-medium rounded-box leading-none
            " on:click={signup} disabled={username?.length === 0 || !nsecBunker?.pubkey || creating} transition:slide>
                {#if !creating}
                    Create account
                    {#if username?.length > 0 && nsecBunker.domain}
                        <span class="text-sm font-light opacity-80" transition:slide>
                            {username}@{nsecBunker.domain}
                        </span>
                    {:else}
                        <!--  -->
                    {/if}
                {:else}
                    <div class="loading loading-sm"></div>
                {/if}
            </button>
        {:else}
            <a href={authUrl} target="_blank" class="button button-primary transition duration-300 flex flex-col gap-1" transition:slide>
                Continue
            </a>
        {/if}
    </div>

    {#if providerOpen}
        <div class="absolute top-0 w-full h-full z-50">
            <NsecBunkerProviderSelect {username} bind:allNsecBunkerProviders bind:value={nsecBunker} bind:open={providerOpen} />
        </div>
    {/if}
</div>

<style lang="postcss">
    .field {
        @apply flex flex-col gap-2;
    }

    label {
        @apply text-white text-lg;
    }
</style>