import currentUser from "$stores/currentUser";
import { ndk } from "$stores/ndk";
import { userArticleCurations, userGenericCuration, userVideoCurations } from "$stores/session";
import { NDKEvent, NDKKind, NDKList } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export function forLaterListInfoForKind(kind: NDKKind) {
    let listKind: NDKKind;
    let listTitle: string;
    
    if (kind === NDKKind.Article) {
        listKind = NDKKind.ArticleCurationSet;
        listTitle = "Read Later";
    } else if (kind === NDKKind.HorizontalVideo) {
        listKind = NDKKind.VideoCurationSet;
        listTitle = "Watch Later";
    } else {
        listKind = NDKKind.BookmarkSet;
        listTitle = "Saved for Later";
    }

    return { listKind, listTitle };
}

export async function toggleSaveForLater(event: NDKEvent) {
    const $ndk = get(ndk);
    const $currentUser = get(currentUser);
    if (!$currentUser) return;

    const { listKind, listTitle } = forLaterListInfoForKind(event.kind!);

    const eventReferenceTag = event.tagId();
    let list: NDKList | undefined;

    switch (listKind) {
        case NDKKind.ArticleCurationSet: {
            list = get(userArticleCurations).get("saved");
            break;
        }
        case NDKKind.VideoCurationSet: {
            list = get(userVideoCurations).get("saved");
            break;
        }
        default: {
            list = get(userGenericCuration)
            break;
        }
    }

    if (!list) {
        list = new NDKList($ndk);
        list.kind = listKind;
        list.title = listTitle;
        list.dTag = "saved";
    }

    const saved = list.items.some(tag => tag[1] === eventReferenceTag) ?? false;

    if (saved) {
        list.tags = list.tags?.filter(tag => tag[1] !== eventReferenceTag);
    } else {
        list.addItem(event.tagReference());
    }

    list.sig = "";
    list.id = "";

    return list.publish();
}