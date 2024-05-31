import { ndk } from '@kind0/ui-common';
import { json } from '@sveltejs/kit';
import Stripe from 'stripe';
import { get } from 'svelte/store';
import { Session } from '../../../app';
import { STRIPE_KEY } from "$env/static/private";
import { createStripeSession } from '$lib/server/stripe';

const APP_URL = import.meta.env.VITE_HOSTNAME === "localhost" ? "http://localhost:5173" : `https://${import.meta.env.VITE_HOSTNAME}`;

export async function POST({ request, locals }) {
    const stripe = new Stripe(STRIPE_KEY, { apiVersion: '2023-10-16' });

    const { pubkey: subscriberPubkey } = locals.session as Session;

    // get url, creator, term, currency, amount, tierId from POST body
    const payload = await request.json();
    const { pubkey: creator, term, currency, amount, tierId, event } = payload;

    const $ndk = get(ndk);
    // const event = await $ndk.fetchEvent(tierId);
    // console.log(event.rawEvent())

    const user = $ndk.getUser({pubkey: creator});
    const profile = await user.fetchProfile();

    // create stripe checkout session
    const session = await stripe.checkout.sessions.create({
        line_items: [
            {
                price_data: {
                    currency: currency,
                    recurring: {
                        interval: term.replace("ly", "")
                    },
                    product_data: {
                        name: profile?.displayName,
                        images: [profile?.image]
                    },
                    unit_amount: amount,
                },
                quantity: 1,
            },
        ],
        mode: 'subscription',
        success_url: `${APP_URL}/${user.npub}/stripe?session={CHECKOUT_SESSION_ID}`,
        cancel_url: `${APP_URL}/${user.npub}`,
    });

    await createStripeSession({
        id: session.id,
        recipientPubkey: creator,
        subscriberPubkey,
        term: term,
        currency: currency,
        amount: parseInt(amount??"12"),
        tierId: tierId,
        event
    });

    return json({ url: session.url });
}

// export async function POST({ request, locals }) {
//     const stripe = new Stripe(stripeSecret, {
//         apiVersion: '2023-10-16'
//     });

//     const payload = await request.json();
//     // const { amount, currency, description, metadata } = payload;

//     console.log(payload);

//     // get sig from header
//     const sig = request.headers['stripe-signature'];

//     let event;

//     try {
//         event = stripe.webhooks.constructEvent(payload, sig, endpointSecret);
//     } catch (err: any) {
//         return text(`Webhook Error: ${err.message}`, { status: 400 });
//     }

//     switch (event.type) {
//         case 'checkout.session.completed': {
//             const session = event.data.object;
//             console.log('checkout.session.completed', session);
//             break;
//         }
//         case 'payment_intent.succeeded': {
//             const paymentIntent = event.data.object;
//             console.log('payment_intent.succeeded', paymentIntent);
//             break;
//         }
//         default:
//             console.log('Unhandled event type', event.type);
//     }

//     return json({ received: true });
// }