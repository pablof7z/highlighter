<script lang="ts">
	import { LoginMethod, login as _login } from '$utils/login';
	import { NDKNip46Signer, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher, onMount } from "svelte";
	import { closeModal } from '$utils/modal';
	import { nip19 } from "nostr-tools";
	import currentUser, { loginMethod, nip46LocalKey, privateKey, userPubkey } from '$stores/currentUser';
	import { bunkerNDK, ndk } from '$stores/ndk';
	import { Input } from '$components/ui/input';
	import { Key, MagnifyingGlass } from 'phosphor-svelte';
	import { Button } from '$components/ui/button';
	import UserProfile from '$components/User/UserProfile.svelte';
	import Avatar from '$components/User/Avatar.svelte';
	import Name from '$components/User/Name.svelte';
	import { newSessionTryNip07 } from '../../../routes/browser-session-setup';

    export let title: string;

    title = "Sign In";
    
    export let value: string = "";
    export let nsec: string = "";
    export let npub = "";
    export let mode: string;

    const dispatch = createEventDispatcher();

    let blocking = false;
    let advanced = false;

    let error: string | undefined;
    let loginStatus: string | undefined;

    onMount(async () => {
        $bunkerNDK.connect(2500);
    });

    async function nip07Login() {
        newSessionTryNip07()
        closeModal();
    }

    async function loginWithNpub() {
        $currentUser = $ndk.getUser({npub});
        $currentUser = $currentUser;
        userPubkey.set($currentUser.pubkey);
        closeModal();
    }

    async function loginNip46(token: string) {
        // $bunkerNDK.connect()
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

        try {
            
            const remoteSigner = new NDKNip46Signer($bunkerNDK, token, localSigner);
            remoteSigner.on("authUrl", (url: string) => {
                window.open(url, "nsecbunker", 'width=300,height=300');
            });
            blocking = true;
            await remoteSigner.blockUntilReady();
            blocking = false;

            if (!existingPrivateKey) {
                $nip46LocalKey = localSigner.privateKey!;
            }

            // nip46ConnectionStatus = 'Authorized';
            $ndk.signer = remoteSigner;
            $currentUser = await remoteSigner.user();
            $currentUser.ndk = $ndk;
            loginMethod.set('nip46');
            userPubkey.set($currentUser.pubkey);

            dispatch('logged-in')

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

            // await $bunkerNDK.connect(2500);

            token = remotePubkey;
            if (secret) token += "#" + secret;
        } catch (e) {
            token = value;
            // console.error(e);
            // error = "Invalid bunker URI";
            // return;
        }

        // if (!token) {
        //     error = "Invalid user";
        //     return;
        // }

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
        privateKey.set(signer.privateKey);
        loginMethod.set('pk');
        dispatch('logged-in')
    }

    let loginType: LoginMethod | undefined;

    function identifyLoginType() {
        if (value.startsWith("npub")) {
            loginType = 'npub';
        } else if (value.startsWith("bunker://")) {
            loginType = 'nip46';
        } else if (value.includes("@")) {
            loginType = 'nip46';
        } else if (value.startsWith("nsec1")) {
            loginType = 'pk';
            nsec = value;
        } else {
            loginType = undefined;
        }
    }

    let nip05: string;
    let searching = false;
    let user: NDKUser | undefined;

    async function findProfile() {
        searching = true;
        try {
            user = await $ndk.getUserFromNip05(nip05);
            console.log(user)
        } finally {
            searching = false;
        }
    }

    function attemptToProcess() {
        identifyLoginType();

        try {
            if (loginType === 'pk') {
                const key = nip19.decode(value);
                loginWithNsec();
            }
        } catch (e) {
            console.error(e);
        }
    }

    function next() {
        identifyLoginType();
        if (loginType === 'nip46') {
            loginWithBunker();
        }
    }
</script>

<div class="flex flex-col gap-4 p-4">
    {#if !user}
        <div class="w-full">
            <div class="field mx-2 w-full">
                <label for="">What profile do you want to use?</label>
                <Input
                    bind:value={value}
                    class="text-lg p-6"
                    placeholder="nsec1..., jack@cashapp.com"
                    on:submit={findProfile}
                    on:paste={attemptToProcess}
                    on:change={attemptToProcess}
                    on:keyup={attemptToProcess}
                />
                <div class="flex flex-col items-start text-sm text-muted-foreground">
                    Enter something to get started:
                    <div class="flex flex-row items-center gap-2">
                        <span>🤙</span>
                        Nostr address (NIP-05)
                    </div>
                    <div class="flex flex-row items-center gap-2">
                        <span>🔑</span>
                        An nsec private key
                    </div>
                </div>
            </div>
        </div>

        <Button
            size="lg"
            class="font-medium text-lg w-full"
            on:click={next}
        >
            {#if loginType === 'pk'}
                Login with nsec
                <Key size={22} class="ml-2" />
            {:else if loginType === 'nip46'}
                Login with remote signer
            {:else if loginType === 'npub'}
                Find Me
                <MagnifyingGlass size={22} class="ml-2" />
            {:else}
                Enter your login information
            {/if}
        </Button>

        <Button
            variant="outline"
            on:click={() => mode = 'signup'}
        >
            Create New Profile
        </Button>

        {#if !!window.nostr}
            <Button
                variant="outline"
                on:click={nip07Login}
            >
                Login with Nostr Extension
            </Button>
        {/if}
    {:else}
        <div class="flex flex-col items-center gap-6">
            <UserProfile {user} let:userProfile let:fetching>
                
                <div class="flex flex-col items-center">
                    <Avatar ring {user} {fetching} {userProfile} size="large" />
                    <h1 class="mb-0">
                        Hi,
                        <Name {user} {fetching} {userProfile} />!
                    </h1>
    
                    <div class="text-muted-foreground text-lg">
                        Welcome to Highlighter!
                    </div>

                </div>

                <p class="text-lg text-muted-foreground grow">
                    Highlighter is a calm place for
                    <span class="text-foreground">content creators</span>
                    to build long-lasting relationships with their audience.
                </p>

                <div class="field mx-2">
                    <label for="">Enter your Nostr private key (starting with "nsec"):</label>
                    <code>
                        <Input
                            bind:value={nsec}
                            class="text-lg p-6"
                            placeholder="nsec1"
                        />
                    </code>
                </div>
        
                <Button
                    variant="accent"
                    size="lg"
                    class="font-bold text-lg w-full"
                >
                    Login with nsec
                    <Key size={22} class="ml-2" />
                </Button>

                <Button
                    variant="outline"
                    class="w-full"
                    on:click={() => mode = 'login'}
                >
                    Continue in Read Only Mode
                </Button>
    
            </UserProfile>
        </div>
            
    {/if}
</div>

<style lang="postcss">
    .field {
        @apply flex flex-col gap-2;
    }

    label {
        @apply text-foreground text-lg;
    }
</style>