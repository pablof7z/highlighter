import { DraftItem, drafts } from "$stores/drafts";
import { ndk } from "$stores/ndk";
import { NDKDraft, NDKEvent } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { getDefaultRelaySet } from "./ndk";
import createDebug from 'debug';
import * as Studio from "$components/Studio";
import * as Composer from "$components/Composer";

const d = createDebug('HL:drafts');

const randomId = () => Math.random().toString(36).substring(7);

export function deleteDraft(draftId: string) {
    drafts.update(drafts => drafts.filter(d => d.id !== draftId));
}

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

type States = Studio.State<Studio.Type> | Composer.State;

export function createDraftId() {
    d('createDraftId');
    return randomId();
}

export function getSerializedPayload(
    type: "studio" | "composer",
    state: States
): string {
    if (type === "studio") {
        return Studio.serialize(state as Studio.State<Studio.Type>);
    } else if (type === "composer") {
        return Composer.serialize(state as Composer.State);
    }

    throw new Error(`Unknown type ${type}`);
}

export function addDraftCheckpoint(
    draftId: string | undefined,
    manuallySaved: boolean,
    state: States,
    type: "studio" | "composer"
): string {
    d('addDraftCheckpoint', { draftId, manuallySaved, type });
    const payload = getSerializedPayload(type, state);
    
    let draft: DraftItem | undefined;
    if (draftId) draft = getDraftById(draftId);

    draftId ??= createDraftId();
    draft ??= { id: draftId, checkpoints: [], type };

    d('draft', draft);

    draft.checkpoints.push({
        id: randomId(),
        time: Date.now(),
        data: payload,
        manuallySaved
    });

    saveDraft(draft);

    return draftId;
}

export function getDraftById(draftId: string) {
    const $drafts = get(drafts);
    return $drafts.find(d => d.id === draftId);
}

export function saveDraft(draft: DraftItem) {
    d('saveDraft', draft);

    const $drafts = get(drafts);
    const index = $drafts.findIndex(d => d.id === draft.id);

    drafts.update($drafts => {
        if (index === -1) {
            $drafts.push(draft);
        } else {
            $drafts[index] = draft;
        }

        return $drafts;
    });
}