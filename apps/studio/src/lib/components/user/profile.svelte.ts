import { ndk } from "@/state/ndk";
import { NDKUser, type NDKUserProfile } from "@nostr-dev-kit/ndk";
import { nip19 } from "nostr-tools";

export class Profile implements NDKUserProfile {
    [key: string]: any;
    profile = $state<NDKUserProfile | null | undefined>(undefined);
    public user: NDKUser | null = null;

    constructor(payload: NDKUser | string) {
        if (payload instanceof NDKUser) {
            this.user = payload;
        } else if (payload.startsWith('npub') || payload.startsWith('nprofile')) {
            try {
                const res = nip19.decode(payload);
                let pubkey: string;
                if (res.type === 'npub') { pubkey = res.data; }
                else if (res.type === 'nprofile') { pubkey = res.data.pubkey; }
                else {
                    console.warn(`Invalid user payload: ${payload}: ${res.type}`);
                    return;
                }

                this.user = new NDKUser({ pubkey });
            } catch (e) {
                console.error(e);
                return;
            }
        } else if (payload.length === 64) {
            this.user = new NDKUser({ pubkey: payload });
        } else {
            console.warn(`Invalid user payload: ${payload}`);
            return;
        }

        this.user.ndk = ndk;

        if (!this.user) {
            console.warn(`Invalid user payload: ${payload}`);
            return;
        }

        // try sync
        const syncProfile = ndk.cacheAdapter?.fetchProfileSync?.(this.user.pubkey);
        if (syncProfile) {
            this.profile = syncProfile;
            return;
        }

        this.user.fetchProfile().then((p) => {
            this.profile = p;
        });
    }

    get pubkey() {
        return this.user?.pubkey;
    }

    get name() {
        return this.profile?.name;
    }

    get displayName() {
        return this.profile?.displayName;
    }

    get image() {
        return this.profile?.image;
    }

    get banner() {
        return this.profile?.banner;
    }

    get bio() {
        return this.profile?.bio;
    }

    get nip05() {
        return this.profile?.nip05;
    }

    get lud06() {
        return this.profile?.lud06;
    }

    get lud16() {
        return this.profile?.lud16;
    }

    get website() {
        return this.profile?.website;
    }
}
