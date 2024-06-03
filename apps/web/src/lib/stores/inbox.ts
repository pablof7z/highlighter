import { derived, get } from "svelte/store";
import { categorizedUserLists } from "./session";
import { ndk } from "$stores/ndk.js";
import { Hexpubkey, NDKKind, NDKList } from "@nostr-dev-kit/ndk";

const INBOX_DTAG = "Highlights";

export const inboxList = derived(categorizedUserLists, ($categorizedUserLists) => {
    let res = $categorizedUserLists.get(INBOX_DTAG);

    if (!res) {
        const $ndk = get(ndk);
        res = new NDKList($ndk);
        res.kind = NDKKind.CategorizedPeopleList;
        res.dTag = INBOX_DTAG;
    }

    return res;
});

export const inboxItems = derived(categorizedUserLists, ($categorizedUserLists) => {
    const inbox = $categorizedUserLists.get(INBOX_DTAG);

    if (!inbox) {
        console.error("Inbox not found");
        return new Set();
    }

    console.log("Inbox items", inbox.items);

    return new Set(inbox.items.map((tag) => tag[1]));
});