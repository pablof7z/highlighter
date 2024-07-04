<script lang="ts">
	import { LoginMethod, login as _login } from '$utils/login';
	import { NDKNip46Signer, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { closeModal } from '$utils/modal';
	import { slide } from "svelte/transition";
	import { nip19 } from "nostr-tools";
	import currentUser, { loginMethod, privateKey, userPubkey } from '$stores/currentUser';
	import { loginState } from '$stores/session';
	import { bunkerNDK, ndk } from '$stores/ndk';
	import { Input } from '$components/ui/input';
	import { NavigationOption } from '../../app';

    export let value: string = "";
    export let nsec: string = "";
    export let npub = "";
    export let actionButtons: NavigationOption[] = [];
    export let mode: string;

    onMount(() => {
        actionButtons = [
            { name: "Signup", fn: signup, buttonProps: { variant: 'secondary', size: 'lg' } },
            { name: "Continue", fn: login, buttonProps: { variant: 'accent', size: 'lg' } },
        ]
    })

    function signup() {
        mode = "signup";
    }

    let blocking = false;
    let advanced = false;

    let error: string | undefined;
    let loginStatus: string | undefined;

    onMount(async () => {
        $bunkerNDK.connect(2500);
    });

    async function loginWithNpub() {
        $currentUser = $ndk.getUser({npub});
        $currentUser = $currentUser;
        userPubkey.set($currentUser.pubkey);
        loginState.set('logged-in');
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
            $currentUser = await remoteSigner.user();
            $currentUser.ndk = $ndk;
            loginMethod.set('nip46');
            userPubkey.set($currentUser.pubkey);

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

        console.log({loginType})

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

    async function loginWithNsec() {
        const signer = new NDKPrivateKeySigner(nsec);
        $currentUser = await signer.user();
        $ndk.signer = signer;
        $currentUser.ndk = $ndk;
        userPubkey.set($currentUser.pubkey);
        loginState.set('logged-in');
        closeModal();
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
            nsec = value;
        }
    }
</script>

<div class="flex flex-col gap-4 p-4">
    <div class="w-full">
        <div class="w-full flex flex-col gap-4">
            <div class="flex-col justify-start items-start gap-3 inline-flex">
                <div class="self-stretch flex-col justify-start items-start gap-1.5 flex">
                    <div class="text-foreground text-base font-medium leading-normal">Username / Nostr address</div>
                    <Input bind:value type="text" placeholder="eg. bob@nostr.me" on:keyup={identifyLoginType} />
                </div>
            </div>

            {#if error}
                <span class="text-danger">{error}</span>
            {:else if loginStatus}
                <div class="text-sm">{loginStatus}</div>
            {:else}
                <div class="text-sm text-muted-foreground">
                    Enter a nostr username, your nsec (private key) or your npub to login in read-only mode.
                </div>
            {/if}
        </div>
    </div>
</div>