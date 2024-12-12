import { BlossomClient } from "blossom-client-sdk/client";
import { generateMediaEventFromBlobDescriptor, signWith } from "./blossom.js";
export class Uploader {
    constructor(blob, server, ndk) {
        this.blob = blob;
        this.server = server;
        this.mime = blob.type;
        this.url = new URL(server);
        this.url.pathname = "/upload";
        this.ndk = ndk;
        this.xhr = new XMLHttpRequest();
    }
    set onProgress(cb) {
        this._onProgress = cb;
    }
    set onError(cb) {
        this._onError = cb;
    }
    set onUploaded(cb) {
        this._onUploaded = cb;
    }
    encodeAuthorizationHeader(uploadAuth) {
        return "Nostr " + btoa(unescape(encodeURIComponent(JSON.stringify(uploadAuth))));
    }
    async start() {
        let _sign = signWith(this.signer, this.ndk);
        const uploadAuth = await BlossomClient.createUploadAuth(_sign, this.blob, "Upload file");
        const encodedAuthHeader = this.encodeAuthorizationHeader(uploadAuth);
        this.xhr.open('PUT', this.url.toString(), true);
        this.xhr.setRequestHeader("Authorization", encodedAuthHeader);
        this.xhr.upload.addEventListener("progress", (e) => this.xhrOnProgress(e));
        this.xhr.addEventListener("load", (e) => this.xhrOnLoad(e));
        this.xhr.addEventListener("error", (e) => this.xhrOnError(e));
        if (this.mime)
            this.xhr.setRequestHeader('Content-Type', this.mime);
        this.xhr.send(this.blob);
        return this.xhr;
    }
    xhrOnProgress(e) {
        if (e.lengthComputable && this._onProgress) {
            this._onProgress(e.loaded / e.total * 100);
        }
    }
    xhrOnLoad(e) {
        const status = this.xhr.status;
        if (status < 200 || status >= 300) {
            if (this._onError) {
                this._onError(new Error(`Failed to upload file: ${status}`));
                return;
            }
            else {
                throw new Error(`Failed to upload file: ${status}`);
            }
        }
        try {
            this.response = JSON.parse(this.xhr.responseText);
        }
        catch (e) {
            throw new Error('Failed to parse response');
        }
        if (this._onUploaded && this.response) {
            this._onUploaded(this.response.url);
        }
    }
    xhrOnError(e) {
        if (this._onError) {
            this._onError(new Error('Failed to upload file'));
        }
    }
    destroy() {
        this.xhr.abort();
    }
    mediaEvent() {
        return generateMediaEventFromBlobDescriptor(this.response, this.ndk);
    }
}
