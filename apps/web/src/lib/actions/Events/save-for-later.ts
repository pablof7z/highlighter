import { NDKArticle, NDKEvent, NDKKind, NDKList, NDKVideo } from '@nostr-dev-kit/ndk';
import { get } from 'svelte/store';
import { userArticleCurations } from '$stores/session.js';
import { ndk } from '$stores/ndk.js';

export async function saveForLater(event: NDKArticle | NDKEvent | NDKVideo) {
    const list = await getSaveForLaterListForEvent(event);

    if (!list) {
        console.error("Could not find a list to save this event to");
        return;
    }

    list.addItem(event);
}

export async function getSaveForLaterListForEvent(
    event: NDKArticle | NDKEvent | NDKVideo
): Promise<NDKList | undefined> {
    const $ndk = get(ndk);
    
    if (event instanceof NDKArticle) {
        const $lists = get(userArticleCurations);

        for (const list of $lists) {
            if (list && list.dTag === "saved") return list;
        }

        const list = new NDKList(get($ndk));
        list.kind = NDKKind.ArticleCurationSet,
        list.title = "Read Later";

        return list;
    }

    return undefined;
}