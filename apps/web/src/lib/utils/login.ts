import type NDK from "@nostr-dev-kit/ndk";
import { NDKEvent, NDKNip07Signer, NDKNip46Signer, NDKPrivateKeySigner, NDKUser } from "@nostr-dev-kit/ndk";
import { newToasterMessage, user } from "@kind0/ui-common";
import { generateLoginEvent } from "$actions/signLoginEvent";

export type LoginMethod = 'none' | 'pk' | 'nip07' | 'nip46';

export async function finalizeLogin() {
    const hostname = import.meta.env.VITE_HOSTNAME;
    console.trace("finalizeLogin", {hostname});
    // fetch jwt
    const loginEvent = await generateLoginEvent(hostname);
    if (!loginEvent) return null;
    const jwt = await fetchJWT(loginEvent);
    if (jwt) {
        localStorage.setItem('jwt', jwt);
        document.cookie = `jwt=${jwt}; path=/; domain=${hostname};`;
    }
}

/**
 * This function attempts to sign in using whatever method was previously
 * used, or a NIP-07 extension.
 */
export async function login(
    ndk: NDK,
    bunkerNDK: NDK,
    method: LoginMethod,
): Promise<NDKUser | null> {
    // Check if there is a localStorage item with the key "nostr-key-method"
    const nostrKeyMethod = method || localStorage.getItem("nostr-key-method");
    let u: NDKUser | null | undefined;

    console.log("login", {nostrKeyMethod});

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
                        await finalizeLogin();
                        resolve(user);
                    });
                }
            });

            return promise;
        }
        default: {
            const promise = new Promise<NDKUser | null>((resolve) => {
                // Attempt to see window.nostr a few times, there is a race condition
                // since the page might begin rendering before the nostr extension is loaded
                let loadAttempts = 0;
                const loadNip07Interval = setInterval(async () => {
                    if (window.nostr) {
                        clearInterval(loadNip07Interval);
                        const user = nip07SignIn(ndk);
                        await finalizeLogin();
                        resolve(user);
                    }

                    if (loadAttempts++ > 10) clearInterval(loadNip07Interval);
                }, 100);
            });

            return promise;
        }
    }

    if (!u) return null;

    await finalizeLogin();

    user.set(u);
    return u;
}

export async function fetchJWT(event: NDKEvent) {
    const formData = new FormData();
    formData.append('event', JSON.stringify(event.rawEvent()));

    const res = await fetch("/api/login", {
        method: "POST",
        headers: { 'accept': 'application/json' },
        body: JSON.stringify({ event: event.rawEvent() })
    });

    if (res.status !== 200) {
        let error: string;
        const data = await res.json();
        console.log(data);

        error = data.error;
        error ??= res.statusText;

        newToasterMessage(`Failed to login: ${error.message}`, "error");
        return false;
    }

    const { jwt } = await res.json();

    return jwt;
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

    console.log("nip46SignIn", {remoteUser, localSigner});
    const remoteSigner = new NDKNip46Signer(bunkerNDK, remoteUser.pubkey, localSigner!);

    await remoteSigner.blockUntilReady();
    ndk.signer = remoteSigner;
    user = remoteUser;
    user.ndk = ndk;

    return user;
}