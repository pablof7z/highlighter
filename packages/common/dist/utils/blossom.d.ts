import NDK, { NDKEvent, NDKSigner, NDKUser } from "@nostr-dev-kit/ndk";
import { BlobDescriptor, EventTemplate, Signer } from "blossom-client-sdk";
export declare function signWith(signer: NDKSigner, ndk: NDK): Signer;
export declare function sign(draft: EventTemplate, signer: NDKSigner | undefined, ndk: NDK): Promise<import("@nostr-dev-kit/ndk").NostrEvent>;
export declare function generateMediaEventFromBlobDescriptor(blob: BlobDescriptor, ndk: NDK): NDKEvent;
export declare function createBlossom({ user, ndk }: {
    user: NDKUser;
    ndk: NDK;
}): (node: HTMLImageElement) => {
    destroy(): void;
} | undefined;
