import { inboxLists } from "$stores/session";
import { ndk } from "$stores/ndk";
import { NDKKind, NDKList, NDKUser, NostrEvent } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export function getInboxListForKind(kind: NDKKind) {
    const $ndk = get(ndk);
    const $inboxLists = get(inboxLists)
    let list = $inboxLists.get(kind.toString());

    list ??= new NDKList($ndk, {
        kind: NDKKind.CategorizedPeopleList,
        tags: [
            [ "d", kind.toString()],
        ]
    } as NostrEvent);

    return list;
}

export async function addToInbox(user: NDKUser, kind: NDKKind) {
    const list = getInboxListForKind(kind);

    await list.addItem(user.referenceTags()[0]);
    await list.publishReplaceable();
}