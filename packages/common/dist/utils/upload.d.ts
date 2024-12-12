import NDK, { NDKSigner } from "@nostr-dev-kit/ndk";
export declare class Uploader {
    private blob;
    private server;
    private _onProgress?;
    private _onError?;
    private _onUploaded?;
    mime: string;
    private url;
    private xhr;
    private response?;
    signer?: NDKSigner;
    private ndk;
    constructor(blob: Blob, server: string, ndk: NDK);
    set onProgress(cb: (progress: number) => void);
    set onError(cb: (error: Error) => void);
    set onUploaded(cb: (url: string) => void);
    private encodeAuthorizationHeader;
    start(): Promise<XMLHttpRequest>;
    private xhrOnProgress;
    private xhrOnLoad;
    private xhrOnError;
    destroy(): void;
    mediaEvent(): import("@nostr-dev-kit/ndk").NDKEvent;
}
