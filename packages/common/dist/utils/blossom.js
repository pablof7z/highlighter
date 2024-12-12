// a blossom URL should finish with a 64 characters hex string and an optional file extension
import { NDKEvent, NDKKind, NDKList, normalize } from "@nostr-dev-kit/ndk";
const blossomUrlRegex = /\/[0-9a-f]{64}(\.\w+)?$/;
export function signWith(signer, ndk) {
    return (draft) => sign(draft, signer, ndk);
}
export async function sign(draft, signer, ndk) {
    const e = new NDKEvent(ndk, draft);
    await e.sign(signer);
    return e.toNostrEvent();
}
export function generateMediaEventFromBlobDescriptor(blob, ndk) {
    const mediaEvent = new NDKEvent(ndk);
    mediaEvent.kind = NDKKind.Media;
    if (blob.type)
        mediaEvent.tags.push(["m", blob.type]);
    if (blob.sha256)
        mediaEvent.tags.push(["x", blob.sha256]);
    if (blob.url)
        mediaEvent.tags.push(["url", blob.url]);
    if (blob.size)
        mediaEvent.tags.push(["size", blob.size.toString()]);
    return mediaEvent;
}
// like https://cdn.hzrd149.com/2759c395ad643686baccdc3693b316ad968b7d95e5d9b764261532b44f42d29c.png
function isBlossomUrl(url) {
    return blossomUrlRegex.test(url);
}
function fileHashFromUrl(url) {
    // get the hash based on the regex
    return url.match(blossomUrlRegex)[0].slice(1, 65);
}
async function getBlossomListFor(user, ndk) {
    const event = await ndk.fetchEvent({
        kinds: [NDKKind.BlossomList], authors: [user.pubkey]
    });
    if (!event) {
        return null;
    }
    return NDKList.from(event);
}
function nextBlossomServerToTry(user, blossomList, hash, attemptedServers = []) {
    const servers = blossomList.getMatchingTags("server").map(tag => tag[1]);
    const server = servers.find(server => !attemptedServers.includes(server));
    return server ?? null;
}
export function createBlossom({ user, ndk }) {
    return function (node) {
        let originalUrl = node.src;
        let url;
        try {
            url = new URL(originalUrl);
        }
        catch (e) {
            return;
        }
        let originalServer = normalize([url.origin])[0];
        let blossomList;
        let hash;
        let attemptedServers = [originalServer];
        const status = document.createElement('span');
        let inserted = false;
        status.textContent = '🌸';
        status.style.fontSize = '1rem';
        status.style.color = 'white';
        status.style.backgroundColor = 'black';
        status.style.padding = '0.5rem';
        status.style.borderRadius = '0.5rem';
        function updateStatus(text) {
            status.textContent = `🌸 ${text}`;
            if (!inserted)
                node.insertAdjacentElement('beforebegin', status);
            inserted = true;
        }
        function finalStatus(text) {
            updateStatus(text);
            setTimeout(() => {
                status.remove();
                inserted = false;
            }, 5500);
        }
        if (isBlossomUrl(originalUrl)) {
            hash = fileHashFromUrl(originalUrl);
        }
        async function handleLoad(event) {
            // add an emoji right below the image saying that it was loaded from a different server
            if (attemptedServers.length > 1) {
                const newUrl = new URL(node.src);
                finalStatus(`Media restored from different Blossom server ${newUrl.hostname}`);
            }
        }
        async function handleError(event) {
            if (!hash)
                return;
            // make sure we have the blossom list
            if (blossomList === undefined) {
                updateStatus(`Using blossom to replace missing media from ${originalServer}`);
                if (!inserted)
                    node.insertAdjacentElement('beforebegin', status);
                blossomList = await getBlossomListFor(user, ndk);
            }
            if (!blossomList) {
                finalStatus('No Blossom list found');
                return;
            }
            const newServer = nextBlossomServerToTry(user, blossomList, hash, attemptedServers);
            if (!newServer) {
                finalStatus('No more servers to try');
                return;
            }
            updateStatus(`Trying new server: ${newServer}`);
            node.src = originalUrl.replace(originalServer, newServer);
            attemptedServers.push(newServer);
        }
        node.addEventListener('error', handleError);
        node.addEventListener('load', handleLoad);
        return {
            destroy() {
                node.removeEventListener('error', handleError);
            }
        };
    };
}
