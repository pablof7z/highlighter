import type NDK from "@nostr-dev-kit/ndk";
import { NDKNip07Signer, NDKNip46Signer, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
import { user } from "@kind0/ui-common";

export type LoginMethod = 'none' | 'pk' | 'nip07' | 'nip46';

/**
 * This function attempts to sign in using whatever method was previously
 * used, or a NIP-07 extension.
 */
export async function login(ndk: NDK, bunkerNDK?: NDK, method?: LoginMethod): Promise<NDKUser | null> {
    // Check if there is a localStorage item with the key "nostr-key-method"
    const nostrKeyMethod = method || localStorage.getItem("nostr-key-method");
    let u: NDKUser | null;

    switch (nostrKeyMethod) {
        case 'none': return null;
        case 'pk': {
            const key = localStorage.getItem('nostr-key');

            if (!key) return null;

            const signer = new NDKPrivateKeySigner(key);
            ndk.signer = signer;
            const u = await signer.u();
            if (u) u.ndk = ndk;
            break;
        }
        case 'nip07':
            u = await nip07SignIn(ndk);
            break;
        case 'nip46': {
            const promise = new Promise<NDKUser | null>((resolve) => {
                const existingPrivateKey = localStorage.getItem('nostr-nsecbunker-key');
                const storedNpub = localStorage.getItem('nostr-target-npub');

                if (storedNpub) {
                    u = ndk.getUser({ npub: storedNpub! });
                }

                if (!bunkerNDK) bunkerNDK = ndk;

                if (existingPrivateKey) {
                    user.set(u);
                    bunkerNDK.connect(2500);
                    bunkerNDK.pool.on('relay:connect', async () => {
                        const user = await nip46SignIn(ndk, bunkerNDK!, existingPrivateKey);
                        resolve(user);
                    });
                }
            });

            return promise;
        }
        default: {
            const promise = new Promise<NDKUser | null>((resolve, reject) => {
                // Attempt to see window.nostr a few times, there is a race condition
                // since the page might begin rendering before the nostr extension is loaded
                let loadAttempts = 0;
                const loadNip07Interval = setInterval(() => {
                    if (window.nostr) {
                        clearInterval(loadNip07Interval);
                        const user = nip07SignIn(ndk);
                        resolve(user);
                    }

                    if (loadAttempts++ > 10) clearInterval(loadNip07Interval);
                }, 100);
            });

            return promise;
        }
    }

    user.set(u);
    return u;
}

/**
 * This function attempts to sign in using a NIP-07 extension.
 */
async function nip07SignIn(ndk: NDK): Promise<NDKUser | null> {
    const storedNpub = localStorage.getItem('nostr-target-npub');
    let user: NDKUser | null = null;

    if (storedNpub) {
        user = new NDKUser({ npub: storedNpub });
        user.ndk = ndk;
    }

    if (window.nostr) {
        try {
            ndk.signer = new NDKNip07Signer();
            user = await ndk.signer?.blockUntilReady();
            user.ndk = ndk;
            if (user) {
                localStorage.setItem('nostr-key-method', 'nip07');
            }
            localStorage.setItem('nostr-target-npub', user.npub);
        } catch (e) {
        }
    }

    return user;
}

/**
 * This function attempts to sign in using a NIP-46 extension.
 */
async function nip46SignIn(ndk: NDK, bunkerNDK: NDK, existingPrivateKey: string): Promise<NDKUser | null> {
    const npub = localStorage.getItem('nostr-target-npub')!;
    const remoteUser = new NDKUser({ npub });
    let user: NDKUser | null = null;
    remoteUser.ndk = bunkerNDK;

    // check if there is a private key stored in localStorage
    let localSigner: NDKPrivateKeySigner | null = null;

    if (existingPrivateKey) {
        localSigner = new NDKPrivateKeySigner(existingPrivateKey);
    }

    if (!localSigner) {
        alert("Local signer not available");
        return null;
    }

    const remoteSigner = new NDKNip46Signer(bunkerNDK, remoteUser.pubkey, localSigner!);

    await remoteSigner.blockUntilReady();
    ndk.signer = remoteSigner;
    user = remoteUser;
    user.ndk = ndk;

    return user;
}