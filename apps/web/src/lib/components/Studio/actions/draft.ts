import { get, Writable } from "svelte/store";
import { addDraftCheckpoint } from "../../../utils/drafts.js";
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