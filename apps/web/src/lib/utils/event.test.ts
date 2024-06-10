import { describe, it, expect, beforeEach } from 'vitest';
import { NDKEvent } from "@nostr-dev-kit/ndk";
import { relaySetForEvent } from "./event";
import { getDefaultRelaySet } from "./ndk";

describe("relaySetForEvent", () => {
    let event: NDKEvent;

    beforeEach(() => {
        event = new NDKEvent();
        event.kind = 30023;
    });
    
    it("returns undefined when there is no h tag", () => {
        const result = relaySetForEvent(event);
        expect(result).toBeUndefined();
    });

    it("returns undefined for kind 1", () => {
        event.kind = 1;
        const result = relaySetForEvent(event);
        expect(result).toBeUndefined();
    });

    describe("when there is an h tag", () => {
        beforeEach(() => {
            event.tags.push(["h", "fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52"]);
        });

        it("returns undefined when there is an h tag and a free tier", () => {
            event.tags.push(["f", "Free"]);
            
            const result = relaySetForEvent(event);
            expect(result).toBeUndefined();
        });

        it("returns default relay list when there is an h tag and no free tier", () => {
            event.tags.push(["f", "Paid"]);
            const def = getDefaultRelaySet();
            const relays = Array.from(def.relays).map(r => r.url);
            const result = relaySetForEvent(event);
            const resRelays = Array.from(result!.relays).map(r => r.url);
            expect(relays).toEqual(resRelays);
        });
    });
});