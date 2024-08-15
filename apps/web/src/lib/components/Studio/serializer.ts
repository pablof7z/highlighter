import { NDKEvent } from "@nostr-dev-kit/ndk";
import * as Studio from "./index.js";

export function serialize(state: Studio.State<Studio.Type>): string {
    const serialized: Record<string, any> = {};

    for (const [key, value] of Object.entries(state)) {
        if (value instanceof NDKEvent) {
            serialized[key] = value.rawEvent();
        } else {
            serialized[key] = value;
        }
    }

    const serializedState = JSON.stringify(serialized);

    console.log('serialized state', serializedState);

    return serializedState;
}

export function deserialize(serialized: string): Studio.State<Studio.Type> {
    const deserialized = JSON.parse(serialized);



    return deserialized;
}