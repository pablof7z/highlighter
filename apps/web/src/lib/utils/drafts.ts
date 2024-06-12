import { CheckpointData, DraftCheckpoint, DraftItem, DraftItemType, drafts, type ArticleCheckpoint } from "$stores/drafts";
import { ndk } from "$stores/ndk";
import { NDKDraft, NDKEvent } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { getDefaultRelaySet } from "./ndk";

const randomId = () => Math.random().toString(36).substring(7);

export async function publishDraft(
    draftItem: DraftItem,
    event: NDKEvent
) {
    if (!event) return;

    console.log('going to publish draft', event.rawEvent());
        
    const $ndk = get(ndk);
    const draft = new NDKDraft($ndk);
    draft.identifier = draftItem.id;
    draft.event = event;
    console.log('draft', draft.rawEvent());
    const relaySet = getDefaultRelaySet();
    await draft.save({relaySet});
    console.log('draft saved');
}

export function addDraftCheckpoint(
    manuallySaved: boolean,
    draftItem: DraftItem | undefined,
    data: CheckpointData,
    type: DraftItemType,
    event: NDKEvent
) {
    const checkpoints: DraftCheckpoint[] = draftItem?.checkpoints ? JSON.parse(draftItem?.checkpoints) : [];
    const checkpoint: DraftCheckpoint = { time: Date.now(), data, manuallySaved }

    if (draftItem) {
        const mostRecentCheckpoint = checkpoints[0];
        // compare the data of the most recent checkpoint with the current data
        if (!manuallySaved && JSON.stringify(mostRecentCheckpoint.data) === JSON.stringify(data)) {
            return false;
        }

        drafts.update((drafts) => drafts.filter(d => d.id !== draftItem!.id));
    } else {
        draftItem = { type, id: randomId(), checkpoints: "" }
    }

    if (manuallySaved) {
        publishDraft(draftItem, event);
    }

    checkpoints.unshift(checkpoint);
    draftItem.checkpoints = JSON.stringify(checkpoints);
    
    try {
        // unshift draftitem into the draft store
        drafts.update((drafts) => [draftItem!, ...drafts]);
    } catch (e) {
        console.error(e);
    }

    return draftItem
}
