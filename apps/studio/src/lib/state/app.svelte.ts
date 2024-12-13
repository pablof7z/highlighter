import type { NDKEvent } from "@nostr-dev-kit/ndk";
import type { ArticleState } from "@/components/Post/state/article.svelte";
import type { ThreadState } from "@/components/Post/state/thread.svelte";

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

    postState = $state<ArticleState | ThreadState | null>(null);
}

export const appState = new AppState();