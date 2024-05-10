<script lang="ts">
	import { login as _login } from '$utils/login';
	import { ndk, bunkerNDK, user } from "@kind0/ui-common";
	import { NDKNip46Signer, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { closeModal } from '$utils/modal';
	import { slide } from "svelte/transition";
	import { nip19 } from "nostr-tools";
	import GlassyInput from '$components/Forms/GlassyInput.svelte';
	import currentUser, { loginMethod, privateKey } from '$stores/currentUser';
	import { loginState } from '$stores/session';

    export let value: string = "";
    export let nsec: string = "";
    export let npub = "";

    let blocking = false;
    let advanced = false;

    let error: string | undefined;

    onMount(async () => {
        $bunkerNDK.connect(2500);
    });

    async function loginWithNpub() {
        $user = $ndk.getUser({npub});
        console.log($user.pubkey);
        $currentUser = $user;
        localStorage.setItem('pubkey', $user.pubkey);

        loginState.set('logged-in');
        closeModal();
    }

    async function loginWithNsec() {
        const pk = nip19.decode(nsec);
        if (!pk.data) {
            error = "Invalid nsec";
            return;
        }
        const key = pk.data as string;
        const signer = new NDKPrivateKeySigner(key);
        const user = await signer.user();
        $ndk.signer = signer;
        loginMethod.set('pk');
        privateKey.set(key);

        _login('pk', user.pubkey);
        console.log(user.pubkey);
        closeModal();
    }

    async function login() {
        if (blocking) {
            blocking = false;
            return;
        }
        let u: NDKUser | undefined;
        let token: string;

        if (value.startsWith("bunker://")) {
            try {
                const uri = new URL(value);
                let remotePubkey = uri.hostname;
                if (remotePubkey.length === 0)
                    remotePubkey = uri.pathname.slice(2);
                const relay = uri.searchParams.get("relay");
                const secret = uri.searchParams.get("secret");

                if (relay) $bunkerNDK.pool.getRelay(relay);

                await $bunkerNDK.connect(2500);

                token = remotePubkey;
                if (secret) token += "#" + secret;
            } catch (e) {
                console.error(e);
                error = "Invalid bunker URI";
                return;
            }
        } else {

            if (value.startsWith("npub")) {
                try {
                    u = $ndk.getUser({npub: value});
                } catch (e) {}
            }

            if (!u) {
                u = await NDKUser.fromNip05(value, $ndk, true);

                if (!u) {
                    error = "User not found" + value;
                    return;
                }

                token = u.pubkey;
            }
        }

        const existingPrivateKey = localStorage.getItem('nostr-nsecbunker-key');
        let localSigner: NDKPrivateKeySigner;``



        if (existingPrivateKey) {
            localSigner = new NDKPrivateKeySigner(existingPrivateKey);

            if (!localSigner.privateKey) {
                localSigner = NDKPrivateKeySigner.generate();
            }
        } else {
            localSigner = NDKPrivateKeySigner.generate();
        }

        if (!token) {
            error = "Invalid user";
            return;
        }

        try {
            const remoteSigner = new NDKNip46Signer($bunkerNDK, token, localSigner);
            remoteSigner.on("authUrl", (url: string) => {
                window.open(url, "nsecbunker", 'width=300,height=300');
            });
            blocking = true;
            await remoteSigner.blockUntilReady();
            blocking = false;

            if (!existingPrivateKey) {
                localStorage.setItem('nostr-nsecbunker-key', localSigner.privateKey!);
            }

            // nip46ConnectionStatus = 'Authorized';
            $ndk.signer = remoteSigner;
            $user = await remoteSigner.user();
            $user.ndk = $ndk;
            loginMethod.set('nip46');
            localStorage.setItem('pubkey', $user.pubkey);

            // loginNip46();

            closeModal();
        } catch (e: any) {
            console.error(e);
            // nip46ConnectionInfo = e;
        }
    }
</script>

<div class="flex flex-col gap-4">
    {#if !advanced}
        <div class="w-full" transition:slide>
            <div class="w-full flex flex-col gap-8">
                <div class="flex-col justify-start items-start gap-3 inline-flex">
                    <div class="self-stretch flex-col justify-start items-start gap-1.5 flex">
                        <div class="text-white text-base font-medium leading-normal">Username / Nostr address</div>
                        <GlassyInput bind:value type="text" placeholder="eg. bob@nostr.me" />
                    </div>
                </div>

                {#if error}
                    <span class="text-danger">{error}</span>
                {/if}

                <button class="button py-3 group" on:click={login}>
                    {#if !blocking}
                        Continue
                    {:else}
                        Cancel
                        <div class="loading loading-sm ml-4"></div>
                    {/if}
                </button>

                <button class="text-white text-sm text-opacity-50" on:click={() => advanced = !advanced}>
                    Advanced
                </button>
            </div>
        </div>
    {:else}
    <div class="w-full" transition:slide>
        <div class="w-full flex flex-col gap-4">
            <div class="self-stretch flex-col justify-start items-start gap-1.5 flex">
                <div class="text-white text-base font-medium leading-normal">Browser Extension Login</div>
                <button class="button py-3 group w-full" disabled={!window.nostr}>
                    Continue
                </button>
                {#if !window.nostr}
                    <span class="text-xs text-opacity-50">
                        You need to install a Nostr browser extension to use this method.
                    </span>
                {/if}
            </div>

            <div class="divider my-0"></div>

            <div class="self-stretch flex-col justify-start items-start gap-1.5 flex">
                <div class="text-white text-base font-medium leading-normal">Private Key Login</div>
                <GlassyInput bind:value={nsec} type="text" placeholder="nsec1..." />
                {#if nsec}
                    <button class="button py-3 group w-full" on:click={loginWithNsec}>
                        Continue
                    </button>
                {/if}
                <span class="text-xs text-opacity-50">
                    This method is not secure:
                    you shouldn't paste your nsec!
                    <!-- <button class="text-white text-sm font-normal underline leading-[19px]">Why?</button> -->
                </span>
            </div>

            <div class="divider my-0"></div>

            <div class="self-stretch flex-col justify-start items-start gap-1.5 flex">
                <div class="text-white text-base font-medium leading-normal">Read-only public login</div>
                <GlassyInput bind:value={npub} type="text" placeholder="npub1..." />
                {#if npub}
                    <button class="button py-3 group w-full" on:click={loginWithNpub}>
                        Continue
                    </button>
                {/if}
            </div>

            <button class="text-white text-sm text-opacity-50" on:click={() => advanced = !advanced}>
                Back
            </button>
        </div>
    </div>
    {/if}
</div>