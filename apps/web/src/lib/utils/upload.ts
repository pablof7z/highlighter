import { BlobDescriptor, BlossomClient, SignedEvent } from "blossom-client-sdk/client";
import { generateMediaEventFromBlobDescriptor, sign } from "./blossom";

export class Uploader {
    private blob: Blob;
    private server: string;
    private _onProgress?: (progress: number) => void;
    private _onError?: (error: Error) => void;
    private _onUploaded?: (url: string) => void;
    public mime;
    private url: URL;
    private xhr: XMLHttpRequest;
    private response?: BlobDescriptor;
    
    constructor(blob: Blob, server: string) {
        this.blob = blob;
        this.server = server;
        this.mime = blob.type;
        this.url = new URL(server);
        this.url.pathname = "/upload";

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

    private encodeAuthorizationHeader(uploadAuth: SignedEvent) {
        return "Nostr " + btoa( unescape (encodeURIComponent( JSON.stringify(uploadAuth) ) ));
    }

    async start() {
        const uploadAuth = await BlossomClient.getUploadAuth( this.blob as Blob, sign as any, "Upload file");
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
        console.log(e);
        console.log(!!this._onProgress);
        if (e.lengthComputable && this._onProgress) {
            console.log(e.loaded / e.total * 100);
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
        return generateMediaEventFromBlobDescriptor(this.response!);
    }
}