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
}

export const appState = new AppState();
