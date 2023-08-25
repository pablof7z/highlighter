import { get as getStore } from "svelte/store";
import { appHandlers } from "$stores/nip89";

export function findNip89Event(dvmPubkey: string, handledKind: number) {
    const $appHandlers = getStore(appHandlers);
    const kindAsString = handledKind.toString();


    return $appHandlers.find((event) => (
        event.pubkey === dvmPubkey &&
        event.getMatchingTags("k").find(kTag => kTag[1] === kindAsString)
    ));
}