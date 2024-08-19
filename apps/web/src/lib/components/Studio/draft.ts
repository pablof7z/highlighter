import NDK, { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
import currentUser from "$stores/currentUser.js";
import { DraftCheckpoint, DraftItem, drafts, ThreadCheckpoint } from "$stores/drafts";
import { ndk } from "$stores/ndk";
import { Thread } from "$utils/thread";
import { toast } from "svelte-sonner";
import { get } from "svelte/store";
import * as Studio from "$components/Studio";
import * as Composer from "$components/Composer";

export function getDraftFromId(draftId: string): DraftItem | undefined {
    const $drafts = get(drafts);
    return $drafts.find(d => d.id === draftId);
}

export function loadDraft(
    draft: DraftItem,
    checkpointId?: string
): Studio.State<Studio.Type> | Composer.State {
    const checkpoints = getDraftItemCheckpoints(draft);
    const checkpoint = getCheckpoint(checkpoints, checkpointId);
    if (!checkpoint) throw new Error("Checkpoint not found");

    const payload = checkpoint?.data;

    const $currentUser = get(currentUser);
    const $ndk = get(ndk) as NDK;

    switch (draft.type) {
        case "thread":
            const thread = Thread.deserialize(
                payload as ThreadCheckpoint,
                $currentUser!,
                $ndk
            );

            throw new Error("Not implemented");
        case "article":
            const { event } = payload as unknown as { event: string };
            const article = NDKArticle.from(JSON.parse(event));
            article.ndk = $ndk;
            if ($currentUser) article.pubkey = $currentUser?.pubkey;

            console.log("article", article);

            return {
                mode: 'edit',
                audience: { scope: 'public' },
                type: Studio.Type.Article,
                draftId: draft.id,
                article,
                withPreview: false,
            } as Studio.State<Studio.Type.Article>;
        case "studio": {
            const state: Studio.State<Studio.Type> = JSON.parse(payload as string) as Studio.State<Studio.Type>;
            state.audience = { scope: 'public' };
            if (state.type === Studio.Type.Article) {
                state.article = NDKArticle.from(state.article);
                state.article.ndk = $ndk;
                if (state.preview) {
                    state.preview = NDKArticle.from(state.preview);
                    state.preview.ndk = $ndk;
                }
            } else if (state.type === Studio.Type.Video) {
                state.video = NDKVideo.from(state.video);
                state.video.ndk = $ndk;
                if (state.preview) {
                    state.preview = NDKVideo.from(state.preview);
                    state.preview.ndk = $ndk;
                }
            }

            return state;
        }
        case "composer":
            return Composer.deserialize(payload as string);
    }
}

export function getDraftItemCheckpoints(draft: DraftItem): DraftCheckpoint[] {
    if (typeof draft.checkpoints === 'string') {
        return JSON.parse(draft.checkpoints);
    } else if (typeof draft.checkpoints === "object") {
        return draft.checkpoints;
    }
}

function getCheckpoint(
    checkpoints: DraftCheckpoint[],
    checkpointId?: string
) {
    if (checkpointId) {
        const c = checkpoints.find(c => c.id === checkpointId || c.time.toString() === checkpointId.toString());
        console.log("state fetched from checkpoint", c);
        if (c) return c;
    }

    const reversedCheckpoints = checkpoints.slice().reverse();
    const lastManuallySaved = reversedCheckpoints.find(c => c.manuallySaved);
    if (lastManuallySaved) return lastManuallySaved;

    return reversedCheckpoints[0];
}

export function getStateFromDraft(
    draft: DraftItem,
    checkpointId?: string
) {
    return loadDraft(draft, checkpointId);
}

export function createStateFromDraftId(
    draftId: string,
    checkpointId?: string
) {
    const draft = getDraftFromId(draftId);
    if (!draft) return;
    return getStateFromDraft(draft, checkpointId);
}