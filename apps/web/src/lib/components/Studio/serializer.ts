import { NDKEvent } from "@nostr-dev-kit/ndk";
import * as Studio from "./index.js";
import { get } from "svelte/store";
import currentUser from "$stores/currentUser.js";

export function serialize(state: Studio.State<Studio.Type>): string {
    const $currentUser = get(currentUser);
    const serialized: Record<string, any> = {};

    for (const [key, value] of Object.entries(state)) {
        if (value instanceof NDKEvent) {
            if ($currentUser) value.pubkey = $currentUser.pubkey;
            serialized[key] = value.rawEvent();
        } else {
            serialized[key] = value;
        }
    }

    const serializedState = JSON.stringify(serialized);

    return serializedState;
}

export function deserialize(serialized: string): Studio.State<Studio.Type> {
    const deserialized = JSON.parse(serialized);



    return deserialized;
}