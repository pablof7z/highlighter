import { ndk } from "$stores/ndk";
import { NDKSubscriptionStart } from '@nostr-dev-kit/ndk';
import { redirect } from '@sveltejs/kit';
import Stripe from 'stripe';
import { get } from 'svelte/store';
import { processNewSubscription } from '$utils/subscriptions';
import createDebug from 'debug';
import { STRIPE_KEY } from '$env/static/private';
import { getStripeSession, updateStripeSession } from '$lib/server/stripe.js';

const debug = createDebug('HL:stripe');

const stripeSecret = STRIPE_KEY;

export async function load({ url }) {
    const stripe = new Stripe(stripeSecret, { apiVersion: '2023-10-16' });

    const session = url.searchParams.get('session');

    debug('session', session);

    if (!session) {
        debug('No session found');
        return redirect(302, '/');
    }

    const checkoutSession = await getStripeSession(session);

    if (!checkoutSession) {
        debug('No session found');
        return redirect(302, '/');
    }

    const $ndk = get(ndk);
    const recipient = $ndk.getUser({pubkey: checkoutSession.recipientPubkey!});

    if (!checkoutSession.paid) {
        debug('Session has not paid before');

        // validate payment
        const sessionData = await stripe.checkout.sessions.retrieve(session);

        debug('sessionData', JSON.stringify(sessionData));

        if (sessionData.payment_status === 'paid') {
            const event = new NDKSubscriptionStart($ndk, JSON.parse(checkoutSession.event!));
            debug("processing new payment")
            await processNewSubscription(event, recipient, $ndk, debug);

            // mark session as paid in db
            await updateStripeSession(session, { paid: true });
            debug('Session marked as paid');
        } else {
            debug('Payment is not paid', sessionData.payment_status);
            debug(sessionData);
        }
    } else {
        debug('Session already paid');
    }

    debug('redirecting to', `/${recipient.npub}`);

    return redirect(302, `/${recipient.npub}`);
}