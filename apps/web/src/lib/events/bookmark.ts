import { ndk } from "@kind0/ui-common";
import { NDKEvent, NDKList } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export async function toggleBookmarkedEvent(event: NDKEvent, list: NDKList) {
    const $ndk = get(ndk);
    const e = new NDKList($ndk, list.rawEvent());

    const eventReferenceTag = event.tagId()
    const saved = list.items.some(tag => tag[1] === eventReferenceTag) ?? false;

    if (saved) {
        e.tags = e.tags?.filter(tag => tag[1] !== eventReferenceTag);
    } else {
        e.addItem(event.tagReference(), undefined, false, "top");
    }

    e.sig = "";
    e.id = "";

    await e.publish();
    return e;
}