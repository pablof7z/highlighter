<script lang="ts">
	import { LoginMethod, login as _login } from '$utils/login';
	import { NDKNip46Signer, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { closeModal } from '$utils/modal';
	import { slide } from "svelte/transition";
	import { nip19 } from "nostr-tools";
	import GlassyInput from '$components/Forms/GlassyInput.svelte';
	import currentUser, { loginMethod, privateKey, userPubkey } from '$stores/currentUser';
	import { loginState } from '$stores/session';
	import { Button } from 'konsta/svelte';

    export let value: string = "";
    export let nsec: string = "";
    export let npub = "";

    let blocking = false;
    let advanced = false;

    let error: string | undefined;
    let loginStatus: string | undefined;

    onMount(async () => {
        $bunkerNDK.connect(2500);
    });

    async function loginWithNpub() {
        $user = $ndk.getUser({npub});
        $currentUser = $user;
        userPubkey.set($user.pubkey);
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

    async function loginNip46(token: string) {
        const existingPrivateKey = localStorage.getItem('nostr-nsecbunker-key');
        let localSigner: NDKPrivateKeySigner;``

        console.log({token})

        if (existingPrivateKey) {
            localSigner = new NDKPrivateKeySigner(existingPrivateKey);

            if (!localSigner.privateKey) {
                localSigner = NDKPrivateKeySigner.generate();
            }
        } else {
            localSigner = NDKPrivateKeySigner.generate();
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
            userPubkey.set($user.pubkey);

            // loginNip46();

            closeModal();
        } catch (e: any) {
            console.error(e);
            // nip46ConnectionInfo = e;
        }
    }

    async function loginWithBunker() {
        let token: string;
        
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

        if (!token) {
            error = "Invalid user";
            return;
        }

        loginNip46(token);
    }

    async function login() {
        console.log({value})
        if (blocking) {
            blocking = false;
            return;
        }
        let u: NDKUser | undefined;
        let token: string;

        identifyLoginType();

        switch (loginType) {
            case 'npub': {
                loginWithNpub();
                break;
            }
            case 'nip46': {
                loginStatus = "Contacting remote signer..."
                if (value.startsWith('bunker://')) {
                    loginWithBunker();
                    break;
                } else {
                    try {
                        loginNip46(value);
                    } catch (e) {}
                }
                break;
            }
            case 'pk': {
                loginWithNsec();
                break;
            }
        }
    }

    let loginType: LoginMethod | undefined;

    function identifyLoginType() {
        if (value.startsWith("npub")) {
            loginType = 'npub';
        } else if (value.startsWith("bunker://")) {
            loginType = 'nip46';
        } else if (value.includes("@")) {
            loginType = 'nip46';
        } else if (value.startsWith("nsec")) {
            loginType = 'pk';
        }
    }
</script>

<div class="flex flex-col gap-4">
    {#if !advanced}
        <div class="w-full" transition:slide>
            <div class="w-full flex flex-col gap-4">
                <div class="flex-col justify-start items-start gap-3 inline-flex">
                    <div class="self-stretch flex-col justify-start items-start gap-1.5 flex">
                        <div class="text-white text-base font-medium leading-normal">Username / Nostr address</div>
                        <GlassyInput bind:value type="text" placeholder="eg. bob@nostr.me" on:keyup={identifyLoginType} />
                    </div>
                </div>

                {#if error}
                    <span class="text-danger">{error}</span>
                {:else if loginStatus}
                    <div class="text-sm">{loginStatus}</div>
                {:else}
                    <div class="text-sm">
                        Enter a nostr username, your nsec (private key) or your npub to login in read-only mode.
                    </div>
                {/if}

                <button class="button button-primary py-2 group" on:click={login}>
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

            <button class="text-white text-sm text-opacity-50" on:click={() => advanced = !advanced}>
                Back
            </button>
        </div>
    </div>
    {/if}
</div>