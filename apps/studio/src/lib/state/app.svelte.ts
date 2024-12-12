import type { NDKEvent } from "@nostr-dev-kit/ndk";
import { ndk } from "./ndk";

class AppState {
    relays = $state<string[]>([
        'wss://relay.primal.net',
        'wss://relay.damus.io',
    ]);
    draftRelays = $state<string[]>([
        'wss://relay.primal.net',
        'wss://f7z.io'
    ]);

    activeEvent = $state<NDKEvent | null>(null);
}

export const appState = new AppState();