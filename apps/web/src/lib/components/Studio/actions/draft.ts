import { get, Writable } from "svelte/store";
import { addDraftCheckpoint, getDraftById } from "../../../utils/drafts.js";
import * as Studio from "../index.js";

export async function saveDraft(
    manuallySaved: boolean,
    state: Writable<Studio.State<Studio.Type>>,
): Promise<boolean> {
    const $state = get(state);

    // save the draft
    let draftId = $state.draftId;
    draftId = await addDraftCheckpoint(
        draftId,
        manuallySaved,
        $state,
        'studio'
    );

    state.update((s) => ({ ...s, draftId }));
    return true;
}


export function shouldSave(state: Studio.State<Studio.Type>) {
    console.log('shouldSaveDraft');
    
    const event = Studio.getEventFromState(state);
    if (!event) return false;
    
    // should have content or a title
    if ((!event.content || event.content.length === 0) && !event.tagValue("title")) return false;

    const draftId = state.draftId;
    if (!draftId) return true;

    const draft = getDraftById(draftId);
    if (!draft) return true;

    const latestCheckpoint = draft.checkpoints[draft.checkpoints.length - 1];
    if (!latestCheckpoint) return true;

    const latestState = Studio.deserialize(latestCheckpoint.data);
    if (!latestState) return true;

    const serialize = Studio.serialize(state);
    return serialize !== latestCheckpoint.data;
}