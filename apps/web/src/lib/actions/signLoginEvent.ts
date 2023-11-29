import { get as getStore } from "svelte/store";
import NDK, { NDKEvent, type NostrEvent } from "@nostr-dev-kit/ndk";
import { newToasterMessage } from "@kind0/ui-common";
import { ndk } from "@kind0/ui-common";

export async function generateLoginEvent(hostname: string): Promise<NDKEvent | undefined> {
    const $ndk = getStore(ndk);
    const event = new NDKEvent($ndk, {
        kind: 27235,
        content: "Sign to verify your account.",
        tags: [
            [ "domain", hostname ]
        ]
    } as NostrEvent);

    try {
        await event.sign();
    } catch (e: any) {
        newToasterMessage(`Failed to sign event: ${e.message}`, "error");
        return undefined;
    }

    return event;
}