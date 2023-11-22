<script lang="ts">
	import { ndk, bunkerNDK, user } from "@kind0/ui-common";
	import { NDKNip46Signer, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { closeModal } from "svelte-modals";

    export let value: string;

    let blocking = false;

    let error: string | undefined;

    onMount(async () => {
        $bunkerNDK.connect(2500);
    });

    async function login() {
        if (blocking) {
            blocking = false;
            return;
        }

        let u: NDKUser | undefined;

        if (value.startsWith("npub")) {
            try {
                u = $ndk.getUser({npub: value});
            } catch (e) {}
        }

        if (!u) {
            u = await NDKUser.fromNip05(value);

            if (!u) {
                error = "User not found";
                return;
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

        try {
            const remoteSigner = new NDKNip46Signer($bunkerNDK, u.pubkey, localSigner);
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
            localStorage.setItem('nostr-key-method', 'nip46');
            localStorage.setItem('nostr-target-npub', $user.npub);

            // loginNip46();

            closeModal();
        } catch (e: any) {
            console.error(e);
            // nip46ConnectionInfo = e;
        }



        // nip46ConnectionStatus = localSigner.privateKey;


    }
</script>

<p class="text-center text-lg mt-2">Log in</p>

<div class="flex flex-col gap-4 mt-6">
    <div class="flex-col justify-start items-start gap-3 inline-flex">
        <div class="self-stretch flex-col justify-start items-start gap-1.5 flex">
            <div class="text-black text-base font-medium leading-normal">Username / Nostr address</div>
            <input bind:value type="text" placeholder="eg. bob@nostr.me" class="w-full px-4 py-3 bg-white rounded-full shadow border border-neutral-200 justify-start items-center gap-2 inline-flex text-black" />
            <button class="text-black text-sm font-normal underline leading-[19px]">Forgot username?</button>
        </div>
    </div>

    {#if error}
        <span class="text-danger">{error}</span>
    {/if}

    <button class="button-primary group" on:click={login}>
        {#if !blocking}
            Continue
        {:else}
            Cancel
            <div class="loading loading-sm ml-4"></div>
        {/if}
    </button>
</div>x