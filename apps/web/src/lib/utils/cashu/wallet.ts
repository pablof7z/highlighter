import { Proof } from "@cashu/cashu-ts";
import NDK, { NDKEvent, NDKEventId, NDKTag } from "@nostr-dev-kit/ndk";
import { NostrEvent } from "nostr-tools";
import { NDKCashuToken, proofsTotalBalance } from "./token";

export class NDKCashuWallet extends NDKEvent {
    private _cachedProofs: Proof[] | undefined;

    constructor(ndk?: NDK, event?: NostrEvent) {
        super(ndk, event);
        this.kind ??= 37375;
    }

    static from(event: NDKEvent) {
        const wallet = new NDKCashuWallet(event.ndk, event.rawEvent());

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

    set mint(url: string) {
        this.removeTag("mint");
        this.tags.push(["mint", url]);  
    }

    get mint(): string | undefined {
        return this.tagValue("mint");
    }

    public addToken(token: NDKCashuToken) {
        this.tags.push(["token", token.id]);
    }

    get tokenIds(): NDKEventId[] {
        const tokens = this.tags
            .filter(t => t[0] === "token")
            .filter(t => t[1].length > 10)
            .map(t => t[1]);
        
        return tokens;
    }

    async balance(forceFetch = false): Promise<number> {
        const proofs = await this.proofs(forceFetch);
        return proofsTotalBalance(proofs);
    }

    async proofs(forceFetch = false): Promise<Proof[]> {
        if (!forceFetch && this._cachedProofs) { return this._cachedProofs; }
        if (!this.ndk) { throw new Error("no ndk"); }

        const tokenIds = this.tokenIds;
        if (tokenIds.length === 0) { return []; }
        
        const tokenEvents = await this.ndk.fetchEvents({
            kinds: [7375 as number],
            ...this.filter(),
        });

        const proofs = Array.from(tokenEvents).map(event => {
            const token = NDKCashuToken.from(event);
            return token.proofs;
        });

        this._cachedProofs = proofs.flat();
        return this._cachedProofs;
    }

    async toNostrEvent(pubkey?: string): Promise<NostrEvent> {
        const encryptedTags: NDKTag[] = [];
        const unencryptedTags: NDKTag[] = [];

        const unencryptedTagNames = [ "d", "client"]

        for (const tag of this.tags) {
            if (unencryptedTagNames.includes(tag[0])) { unencryptedTags.push(tag); }
            else { encryptedTags.push(tag); }
        }

        this.tags = unencryptedTags.filter(t => t[0] !== "client");
        this.content = JSON.stringify(encryptedTags);
        
        return super.toNostrEvent(pubkey);
    }
}