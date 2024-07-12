import { creatorRelayPubkey } from '$utils/const';
import { checkForZapReceipt, processNewSubscription } from '$utils/subscriptions.js';
import { ndk } from "$stores/ndk";
import { NDKSubscriptionStart } from '@nostr-dev-kit/ndk';
import { get } from 'svelte/store';
import createDebug from "debug";
import { json } from '@sveltejs/kit';

const debug = createDebug('HL:/api/subscriptions/validate');

export async function POST({ request }) {
    const $ndk = get(ndk);
	const { event } = await request.json();

    $ndk.connect()

    console.log("looking for event", event);

    const e = await $ndk.fetchEvent(event)

    console.log(e?.id);
    
    if (!e) throw new Error("Event not found")

    console.log("event", e.rawEvent())

    const subscriptionStart = NDKSubscriptionStart.from(e);

    const check = async () => {
        try {
            console.log("checking for zap receipt");
            const res = await checkForZapReceipt(subscriptionStart, creatorRelayPubkey, $ndk)
            if (!res) {
                setTimeout(check, 2500);
            }
        } catch (e) {
            console.log("error checking for zap receipt", e);
            debug('error checking for zap receipt', e);
        }
    }

    await check();

    return json({ success: true });
}

