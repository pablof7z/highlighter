import { type NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
import type { EventType } from "../../../../app";

export function getEventType(event: NDKEvent): EventType | undefined {
    if (event.kind === NDKKind.Article) {
        const mTag = event.getMatchingTags("m")[0];

        if (!mTag) return "article";

        const isVideo = mTag[1] === "video";
        const itemType = isVideo ? "video" : "article";

        return itemType;
    } else if (event.kind === NDKKind.GroupNote) {
        return "group-note";
    } else {
        console.trace("Unknown event type", event.rawEvent());
        alert("Unknown event type",);
    }

    return undefined;
}