import NDK, { NDKArticle } from "@nostr-dev-kit/ndk";
import currentUser from "$stores/currentUser.js";
import { CheckpointData, DraftCheckpoint, DraftItem, drafts, ThreadCheckpoint } from "$stores/drafts";
import { ndk } from "$stores/ndk";
import { Thread } from "$utils/thread";
import { toast } from "svelte-sonner";
import { get } from "svelte/store";

export function getDraft(
    draftId: string,
    checkpointId?: string
) {
    const $drafts = get(drafts);
    const draft = $drafts.find(d => d.id === draftId);

    if (!draft) {
        toast.error("Draft not found");
        return;
    }

    const checkpoints = getDraftItemCheckpoints(draft);
    const checkpoint = getCheckpoint(checkpoints, checkpointId);
    if (!checkpoint) return;

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

            return { draft, thread };
        case "article":
            const { event } = payload as ArticleCheckpoint;
            const article = NDKArticle.from(JSON.parse(event));
            article.ndk = $ndk;
            return { draft, article };
    }
}

function getDraftItemCheckpoints(draft: DraftItem): DraftCheckpoint[] {
    return JSON.parse(draft.checkpoints);
}

function getCheckpoint(
    checkpoints: DraftCheckpoint[],
    checkpointId?: string
) {
    if (checkpointId) {
        const c = checkpoints.find(c => c.id === checkpointId);
        if (c) return c;
    }

    const firstManuallySaved = checkpoints.find(c => c.manuallySaved);

    if (firstManuallySaved) return firstManuallySaved;

    return checkpoints[0];
}