import LnQrModal from "$modals/LnQrModal.svelte";
import { ndk } from "$stores/ndk";
import { openModal } from "$utils/modal";
import { Hexpubkey, NDKArticle, NDKEvent, NDKRelaySet, NostrEvent } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

export async function requestTTS(
    article: NDKArticle,
    dvmPubkey?: Hexpubkey
) {
    const $ndk = get(ndk);
    const relay = $ndk.pool.getRelay("wss://relay.damus.io")
    const relaySet = new NDKRelaySet(new Set([relay]), $ndk);
    const e = new NDKEvent($ndk, {
        kind: 5250,
    } as NostrEvent)
    e.tags.push(["i", article.id, "event"]);
    e.tags.push(["param", "language", "en"]);
    if (dvmPubkey) e.tags.push(["p", dvmPubkey])
    e.tags.push(["relays", "wss://relay.primal.net", "wss://relay.f7z.io", "wss://nos.lol"])
    if (article.title) e.tags.push(["title", article.title])
    if (article.summary) e.tags.push(["summary", article.summary])
    e.tags.push(["author", article.pubkey])
    await e.sign();

    const dvmSub = $ndk.subscribe(e.filter(), {}, relaySet);

    dvmSub.on("event", (e) => {
        console.log(e);

        if (e.kind === 7000) {
            toast.success(e.content);
        }

        const amount = e.getMatchingTags("amount")[0];
        console.log(amount);
        openModal(LnQrModal, { title: "Pay DVM", satAmount: parseInt(amount[1])/1000, pr: amount[2] })
    });
        
    await e.publish();

    return e;
}