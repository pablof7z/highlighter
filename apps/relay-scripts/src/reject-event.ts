import { NDKEvent, type NostrEvent } from "@nostr-dev-kit/ndk";

const activeSubscriptions = {
    "e869cdc5114a2b067a99bbcdb6cbd1e80696efd0c352f1c1e6d0be8fc440f807": [
        "85c3d32d805fa222a51379b42d4e9483b1bda8f24ed1362b59503784f30edf98"
    ]
}

function allowAuthorOnTheirOwnGroup(event: NostrEvent, hTag: string): boolean | undefined {
    const author = event.pubkey;

    if (author === hTag) return true;
}

function allowActiveMembersToReply(event: NostrEvent, hTag: string): boolean | undefined {
    const author = event.pubkey;

    console.log(JSON.stringify({hTag, activeSubscriptions: activeSubscriptions[hTag]}));

    if (activeSubscriptions[hTag].includes(author)) return true;
}

function allowReactionsFromAnyone(event: NostrEvent, hTag: string): boolean | undefined {
    if (event.kind === 7) return true;
}

type Connection = {
    ip?: string,
    pubkey?: string,
    store?: Object
};

export default function(event: NostrEvent, relay: any, connection: Connection) {
    console.log(JSON.stringify({event, relay, connection}));

    if (!connection.pubkey) {
        console.log("Authentication required");
        return "Authentication required"
    }

    const hTag: string | undefined = event.tags.find(tag => tag[0] === "h")?.[1];

    const eventCount = relay.query({}).length;

    console.log(JSON.stringify({hTag, eventCount}));

    if (hTag) {
        try {
            if (allowReactionsFromAnyone(event, hTag)) return;
            if (allowAuthorOnTheirOwnGroup(event, hTag)) return;
            if (allowActiveMembersToReply(event, hTag)) return;
        } catch (e) {
            console.trace(e);
            return e.message;
        }

        return "Not allowed";
    }
}