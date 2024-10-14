<script lang="ts">
    import { NDKPrivateKeySigner, NDKUser, NDKNip46Signer, NDKEvent } from "@nostr-dev-kit/ndk";
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { createEventDispatcher, onMount } from 'svelte';
	import currentUser, { loginMethod, nip46LocalKey, userPubkey } from "$stores/currentUser";
	import { bunkerNDK, ndk } from '$stores/ndk.js';
	import { createGuestAccount } from "$utils/user/guest";
	import Input from "$components/ui/input/input.svelte";
	import Button from "$components/ui/button/button.svelte";
	import { ArrowRight, Play } from "phosphor-svelte";
	import { fillInSkeletonProfile, pkSignup } from "$utils/login";
	import AvatarSelection from "$components/Signup/AvatarSelection.svelte";
    import { createNewWallet } from "$lib/actions/wallet/new.js";
	import { closeModal } from "$utils/modal";
    import * as Card from "$components/ui/card";

    export let mode: string;
    export let title: string;

    title = 'Welcome!'

    const signer = NDKPrivateKeySigner.generate();

    function login() {
        mode = "login";
    }

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
        const returnUrl = "https://highlighter.com" || window.location.origin;
        const callbackUrl = new URL(callbackPath, returnUrl);
        console.log('callbackUrl is', callbackUrl.toString());
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
            $nip46LocalKey = localSigner.privateKey!;
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
            $currentUser = u;
            $ndk.signer = remoteSigner;
            loginMethod.set('nip46');
            userPubkey.set($currentUser.pubkey);
            popup?.close();
            dispatch("signed-up");
        } catch (e) {
            console.error(e);
            alert(e);
            creating = false;
        }
    }

    function continueAsGuest() {
        createGuestAccount().then(() => {
            dispatch("signed-up");
        });
    }

    let avatar: string;

    $: username = username.toLowerCase().replace(/[^a-z0-9_]/g, "");

    let name: string;

    async function startSignup() {
        await pkSignup();

        await fillInSkeletonProfile({
            name,
            picture: avatar,
        })

        closeModal();

        // create wallet
        setTimeout(() => {
            createNewWallet()
        }, 5000);

    }
</script>

<Card.Root>
    <Card.Content class="flex flex-col gap-6">
        <h1 class="pt-3 text-center">Sign Up</h1>

        <p class="text-muted-foreground grow">
            Highlighter is a
            calm place for
            <span class="text-foreground">content creators</span>
            to build long-lasting relationships with their audience.
        </p>

        <div
        class="flex flex-col gap-4 transition-opacity duration-0"
    >
        <div class="flex flex-col items-center gap-2 w-full">
            <AvatarSelection bind:avatar />
        </div>

        <div class="field mx-2">
            <label for="">What should we call you?</label>

            <Input
                bind:value={name}
                class="text-lg p-6"
                placeholder="Johnnie Appleseed"
            />
        </div>

        <Button
            on:click={startSignup}
        >
            Start
            <ArrowRight size={22} class="ml-2" />
        </Button>

        <Button
            variant="outline"
            on:click={() => mode = 'login'}
        >
            Already on Highlighter or Nostr?
        </Button>
    </div>
        
    </Card.Content>
</Card.Root>
