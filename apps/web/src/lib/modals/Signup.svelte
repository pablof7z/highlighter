<script lang="ts">
    import { NDKPrivateKeySigner, NDKUser, NDKNip46Signer, NDKEvent } from "@nostr-dev-kit/ndk";
	import { bunkerNDK, ndk, user } from "@kind0/ui-common";
	import NsecBunkerProviderSelect from "$components/Forms/NsecBunkerProviderSelect.svelte";
	import type { NsecBunkerProvider } from "../../app";
	import { slide } from "svelte/transition";
	import { loginState } from '$stores/session';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { createEventDispatcher } from 'svelte';
    import CaretDown from "phosphor-svelte/lib/CaretDown";

    const dispatch = createEventDispatcher();

    let email: string;
    let username: string = "";
    let nsecBunker: NsecBunkerProvider = {
        pubkey: "73c6bb92440a9344279f7a36aa3de1710c9198b1e9e8a394cd13e0dd5c994c63",
        domain: "highlighter.com"
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
        const nip05 = await NDKUser.fromNip05([ username, domain ].join("@"), $ndk);

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
            localStorage.setItem('pubkey', $user.pubkey);
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
    >
        <div class="field">
            <label>
                Choose a username
            </label>
            <div class="
                border flex flex-row flex-nowrap
                !bg-black/30 !border-opacity-20 rounded-full text-lg text-white/80
                w-full items-center placeholder:!text-zinc-400 !ring-none
                border-white overflow-clip gap-2
                justify-between
            ">
                <input
                    tabindex={1}
                    bind:value={username}
                    type="text"
                    autocomplete="off"
                    placeholder="Username"
                    class="lowercase !border-none !ring-0 !outline-none pl-6 w-1/2 border grow !bg-transparent"
                    on:focus={() => usernameHasFocus = true}
                    on:blur={() => {usernameHasFocus = false; checkUsername(); }}
                />
                <span class="text-lg text-neutral-500 font-medium">@</span>
                <div class="border-0 inset-y-1 flex items-center text-sm text-gray-500
                    bg-black/60 hover:bg-black/70 rounded-r-full py-4 pl-2">
                    <button class="border-0 flex items-center text-sm text-neutral-200 focus:ring-0 focus:outline-none overflow-hidden" on:click={() => providerOpen = !providerOpen}>
                        {#if nsecBunker?.domain}
                            <span class="underline underline-offset-1 transition-all duration-300">{nsecBunker.domain}</span>
                        {/if}
                        <CaretDown class="w-5 h-5 ml-2 mr-3" />
                    </button>
                </div>
            </div>
            <div class="text-sm opacity-60 transition-all duration-300 -mt-1 hidden">
                <span class="text-white">Don't worry you can change it later.</span>
            </div>

            {#if usernameTaken}
                <div class="alert alert-error bg-error/20 text-white/80 py-3 my-3 text-sm font-medium" transition:slide>
                    This username is already taken.
                </div>
            {/if}
        </div>

        <div class="w-full h-full" class:hidden={!providerOpen}>
            <NsecBunkerProviderSelect
                {username}
                bind:allNsecBunkerProviders
                bind:value={nsecBunker}
                on:click={() => {
                    providerOpen = false
                    checkUsername()
                }}
            />
        </div>

        {#if !popupNotOpened}
            <button class="
                button transition duration-300 flex flex-col
                py-4 font-medium rounded-box leading-none
            " on:click={signup} disabled={username?.length === 0 || !nsecBunker?.pubkey || creating} transition:slide>
                {#if !creating}
                    Let's go!
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
</div>

<style lang="postcss">
    .field {
        @apply flex flex-col gap-2;
    }

    label {
        @apply text-white text-lg;
    }
</style>