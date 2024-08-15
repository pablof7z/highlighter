import { NDKEvent } from "@nostr-dev-kit/ndk";
import * as Composer from "./index.js";

export function serialize(state: Composer.State): string {
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

export function deserialize(serialized: string): Composer.State {
    const deserialized = JSON.parse(serialized);
    
    return deserialized;
}