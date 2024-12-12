import { BlossomClient } from "blossom-client-sdk/client";
import { generateMediaEventFromBlobDescriptor, sign, signWith } from "./blossom.js";
import NDK, { NDKSigner, NostrEvent } from "@nostr-dev-kit/ndk";
import { Signer } from "blossom-client-sdk";

export class Uploader {
    private blob: Blob;
    private server: string;
    private _onProgress?: (progress: number) => void;
    private _onError?: (error: Error) => void;
    private _onUploaded?: (url: string) => void;
    public mime;
    private url: URL;
    private xhr: XMLHttpRequest;
    private response?: any;
    public signer?: NDKSigner;
    private ndk: NDK;
    
    constructor(blob: Blob, server: string, ndk: NDK) {
        this.blob = blob;
        this.server = server;
        this.mime = blob.type;
        this.url = new URL(server);
        this.url.pathname = "/upload";
        this.ndk = ndk;

        this.xhr = new XMLHttpRequest();
    }

    set onProgress(cb: (progress: number) => void) {
        this._onProgress = cb;
    }

    set onError(cb: (error: Error) => void) {
        this._onError = cb;
    }

    set onUploaded(cb: (url: string) => void) {
        this._onUploaded = cb;
    }

    private encodeAuthorizationHeader(uploadAuth: NostrEvent) {
        return "Nostr " + btoa( unescape (encodeURIComponent( JSON.stringify(uploadAuth) ) ));
    }

    async start() {
        let _sign: Signer = signWith(this.signer!, this.ndk);
        const uploadAuth = await BlossomClient.createUploadAuth(_sign, this.blob as Blob, "Upload file");
        const encodedAuthHeader = this.encodeAuthorizationHeader(uploadAuth);

        this.xhr.open('PUT', this.url.toString(), true);
        this.xhr.setRequestHeader("Authorization", encodedAuthHeader);
        this.xhr.upload.addEventListener("progress", (e) => this.xhrOnProgress(e));
        this.xhr.addEventListener("load", (e) => this.xhrOnLoad(e));
        this.xhr.addEventListener("error", (e) => this.xhrOnError(e));
        
        if (this.mime) this.xhr.setRequestHeader('Content-Type', this.mime);

        this.xhr.send(this.blob);

        return this.xhr;
    }

    private xhrOnProgress(e: ProgressEvent) {
        if (e.lengthComputable && this._onProgress) {
            this._onProgress(e.loaded / e.total * 100);
        }
    }

    private xhrOnLoad(e: ProgressEvent) {
        const status = this.xhr.status;

        if (status < 200 || status >= 300) {
            if (this._onError) {
                this._onError(new Error(`Failed to upload file: ${status}`));
                return
            } else {
                throw new Error(`Failed to upload file: ${status}`);
            }
        }

        try {
            this.response = JSON.parse(this.xhr.responseText);
        } catch (e) {
            throw new Error('Failed to parse response');
        }

        if (this._onUploaded && this.response) {
            this._onUploaded(this.response.url);
        }
    }

    private xhrOnError(e: ProgressEvent) {
        if (this._onError) {
            this._onError(new Error('Failed to upload file'));
        }
    }

    destroy() {
        this.xhr.abort();
    }

    mediaEvent() {
        return generateMediaEventFromBlobDescriptor(this.response!, this.ndk);
    }
}