import { userGenericCuration } from "$stores/session";
import { ndk } from "$stores/ndk.js";
import { NDKEvent, NDKKind, NDKList } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export async function toggleBookmarkedEvent(
    event: NDKEvent,
    list?: NDKList
) {
    list ??= get(userGenericCuration);
    
    const $ndk = get(ndk);
    const e = new NDKList($ndk, list.rawEvent());

    const eventReferenceTag = event.tagId()
    const saved = list.items.some(tag => tag[1] === eventReferenceTag) ?? false;

    console.log("toggleBookmarkedEvent", saved, eventReferenceTag, list.items);

    if (saved) {
        e.tags = e.tags?.filter(tag => tag[1] !== eventReferenceTag);
    } else {
        e.addItem(event.tagReference(), undefined, false, "top");
    }

    e.sig = "";
    e.id = "";
    e.created_at = undefined;

    await e.sign();
    e.publish();
    return e;
}