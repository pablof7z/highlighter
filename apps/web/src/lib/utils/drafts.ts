import { CheckpointData, DraftCheckpoint, DraftItem, DraftItemType, drafts } from "$stores/drafts";

const randomId = () => Math.random().toString(36).substring(7);

export function addDraftCheckpoint(
    manuallySaved: boolean,
    draftItem: DraftItem | undefined,
    data: CheckpointData,
    type: DraftItemType,
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