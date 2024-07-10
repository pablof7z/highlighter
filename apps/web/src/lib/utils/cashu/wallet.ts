import { Proof } from "@cashu/cashu-ts";
import NDK, { NDKEvent, NDKEventId, NDKTag, NDKUser } from "@nostr-dev-kit/ndk";
import { NostrEvent } from "nostr-tools";
import { NDKCashuToken, proofsTotalBalance } from "./token";

export class NDKCashuWallet extends NDKEvent {
    public tokens: NDKCashuToken[] = [];

    constructor(ndk?: NDK, event?: NostrEvent) {
        super(ndk, event);
        this.kind ??= 37375;
    }

    static async from(event: NDKEvent) {
        const wallet = new NDKCashuWallet(event.ndk, event.rawEvent());

        const prevContent = wallet.content;
        try {
            await wallet.decrypt();
        } catch (e) {
        }
        wallet.content ??= prevContent;

        const contentTags = JSON.parse(wallet.content);
        wallet.tags = [...contentTags, ...wallet.tags];
        
        return wallet;
    }

    set relays(urls: WebSocket['url'][]) {
        this.tags = this.tags.filter(t => t[0] !== "relay");
        for (const url of urls) {
            this.tags.push(["relay", url]);
        }
    }

    get relays(): WebSocket['url'][] {
        const r = [];
        for (const tag of this.tags) {
            if (tag[0] === "relay") { r.push(tag[1]); }
        }

        return r;
    }

    set mints(urls: WebSocket['url'][]) {
        this.tags = this.tags.filter(t => t[0] !== "mint");
        for (const url of urls) {
            this.tags.push(["mint", url]);
        }
    }

    get mints(): WebSocket['url'][] {
        console.log('getting mints', this.tags)
        const r = [];
        for (const tag of this.tags) {
            if (tag[0] === "mint") { r.push(tag[1]); }
        }

        return Array.from(new Set(r));
    }

    set name(url: string) {
        this.removeTag("name");
        this.tags.push(["name", url]);  
    }

    get name(): string | undefined {
        return this.tagValue("name");
    }

    async balance(forceFetch = false): Promise<number> {
        const proofs = await this.proofs(forceFetch);
        return proofsTotalBalance(proofs);
    }

    async toNostrEvent(pubkey?: string): Promise<NostrEvent> {
        const encryptedTags: NDKTag[] = [];
        const unencryptedTags: NDKTag[] = [];

        const unencryptedTagNames = [ "d", "client" ]

        for (const tag of this.tags) {
            if (unencryptedTagNames.includes(tag[0])) { unencryptedTags.push(tag); }
            else { encryptedTags.push(tag); }
        }

        this.tags = unencryptedTags.filter(t => t[0] !== "client");
        this.content = JSON.stringify(encryptedTags);

        const user = await this.ndk!.signer!.user();

        await this.encrypt(user);
        
        return super.toNostrEvent(pubkey);
    }
}