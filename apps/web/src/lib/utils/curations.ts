import { userArticleCurations, userVideoCurations } from "$stores/session";
import NDK, { NDKEvent, NDKKind, NDKList } from "@nostr-dev-kit/ndk";

export function curationHasEvent(
    curation: NDKList,
    event: NDKEvent
) {
    const tagId = event.tagId();
    if (curation.items.map(tag => tag[1]).includes(tagId)) {
        return true;
    }

    return false;
}

export async function toggleItemInCuration(
    curation: NDKList,
    event: NDKEvent,
) {
    const adding = !(await curationHasEvent(curation, event));

    const isEncrypted = (await curation.encryptedTags()).length > 0;
    curation.id = "";
    curation.sig = "";
    curation.created_at = undefined;

    if (adding) {
        await curation.addItem(event.tagReference(), undefined, isEncrypted);
    } else {
        const index = curation.items.findIndex(tag => tag[1] === event.tagId());
        if (index  === -1) {
            throw `Tag ${event.tagId()} not found in curation ${curation.title}`;
        }
        
        await curation.removeItem(index, isEncrypted);
    }

    await curation.sign();
    await curation.publish();
}

export async function createNewCuration(
    ndk: NDK,
    name: string,
    event: NDKEvent,
) {
    const curation = new NDKList(ndk);
    curation.kind = getCurationKindForEvent(event);
    curation.title = name;
    await toggleItemInCuration(curation, event);
}

export function getCurationKindForEvent(event: NDKEvent) {
    switch (event.kind) {
        case NDKKind.Article:
            return NDKKind.ArticleCurationSet
        case NDKKind.HorizontalVideo:
            return NDKKind.VideoCurationSet;
        default:
            throw `Not supported curation button for kind ${event.kind}`;
    }
}

export function getStoreForCurationEvent(event: NDKEvent) {
    const kind = getCurationKindForEvent(event);
    switch (kind) {
        case NDKKind.ArticleCurationSet:
            return userArticleCurations;
        case NDKKind.VideoCurationSet:
            return userVideoCurations;
        default:
            throw `Not supported curation button for kind ${kind}`;
    }
}