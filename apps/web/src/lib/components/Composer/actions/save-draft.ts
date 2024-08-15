import { get, Writable } from 'svelte/store';
import type { State } from '../index.js';
import { addDraftCheckpoint } from '../../../utils/drafts.js';

export default function (
    state: Writable<State>,
    manuallySaved: boolean
) {
    const $state = get(state);
    if ($state.draftId) {}

    const draftId = addDraftCheckpoint(
        $state.draftId,
        manuallySaved,
        $state,
        'composer'
    )
    state.update(s => ({ ...s, draftId }));
}