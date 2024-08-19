import { get, Writable } from 'svelte/store';
import type { State } from '../index.js';
import { addDraftCheckpoint } from '../../../utils/drafts.js';

export default function (
    state: Writable<State>,
    manuallySaved: boolean
) {
    const $state = get(state);

    if (!shouldSaveDraft($state)) {
        console.log('no need to save')
        return false;
    }

    const draftId = addDraftCheckpoint(
        $state.draftId,
        manuallySaved,
        $state,
        'composer'
    )
    state.update(s => ({ ...s, draftId }));
}

function shouldSaveDraft(state: State) {
    // should have content
    if (!state.content || state.content.length === 0) return false;

    const draftId = state.draftId;
    if (!draftId) return true;


}