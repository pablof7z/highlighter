import { DraftCheckpoint, DraftItem, ThreadCheckpoint, ThreadCheckpointItem } from "$stores/drafts";
import NDK, { NDKEvent, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
import { Writable, get } from "svelte/store";

export type ThreadItem = {
    event: NDKEvent,
    urls: string[],
};

export class Thread {
    public items: ThreadItem[];
    private kind: NDKKind;
    private user: NDKUser;
    private ndk: NDK;

    constructor(kind: NDKKind, user: NDKUser, ndk: NDK) {
        this.kind = kind;
        this.items = [];
        this.user = user;
        this.ndk = ndk;

        this.newItem();
    }

    static deserialize(data: ThreadCheckpoint, user: NDKUser, ndk: NDK) {
        const thread = new Thread(NDKKind.Text, user, ndk);
        thread.items = data.items.map((i: ThreadCheckpointItem) => ({
            event: NDKEvent.deserialize(ndk, i.event),
            urls: i.urls
        }));
        thread.kind = thread.items[0]?.event.kind as NDKKind;

        // ensure all events have a random id
        thread.items.forEach(i => {
            if (!i.event.id) {
                i.event.id = Math.random().toString(36).substring(7);
            }
        });

        return thread;
    }

    public newItem() {
        const e = new NDKEvent(this.ndk);
        e.kind = this.kind;
        e.pubkey = this.user.pubkey;
        e.created_at = Math.floor(Date.now() / 1000);
        e.id = Math.random().toString(36).substring(7);
        this.items.push({ event: e, urls: [] });
    }

    public removeItem(i: number) {
        this.items.splice(i, 1);
    }

    public serialize(): ThreadCheckpoint {
        return {
            items: this.items.map(i => ({
                event: i.event.serialize(true, true),
                urls: i.urls
            }))
        }
    }
}

export function saveDraft(
    manuallySaved = false,
    draftItem: DraftItem | undefined,
    draftStore: Writable<DraftItem[]>,
    thread: Thread,
): DraftItem | false {
    const draftCheckpoints: DraftCheckpoint[] = draftItem?.checkpoints ? JSON.parse(draftItem?.checkpoints) : [];
    const serialized = thread.serialize();
    const checkpoint: DraftCheckpoint = {
        time: Date.now(),
        data: serialized,
        manuallySaved
    }

    if (draftItem) {
        const mostRecentCheckpoint = draftCheckpoints[0];
        // compare the data of the most recent checkpoint with the current data
        if (!manuallySaved && JSON.stringify(mostRecentCheckpoint.data) === JSON.stringify(serialized)) {
            return false;
        }

        draftStore.update((drafts) => drafts.filter(d => d.id !== draftItem!.id));
    } else {
        draftItem = {
            type: "thread",
            id: Math.random().toString(36).substring(7),
            checkpoints: "",
        }
    }

    draftCheckpoints.unshift(checkpoint);
    draftItem.checkpoints = JSON.stringify(draftCheckpoints);

    try {
        // unshift draftitem into the draft store
        draftStore.update((drafts) => [draftItem!, ...drafts]);
    } catch (e) {
        console.error(e);
    }

    return draftItem;
}