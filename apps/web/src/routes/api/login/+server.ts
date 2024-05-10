import { JWT_ACCESS_SECRET } from '$env/static/private';
import { verifySignature, type Event } from 'nostr-tools';
import { NDKEvent } from '@nostr-dev-kit/ndk';
import { json, text } from '@sveltejs/kit';
import jwt from 'jsonwebtoken';
import type { Session } from '../../../app';
import { createUser, getUserFromPubkey } from '$lib/server/user';
import { getWalletForPubkey } from '$lib/server/wallet';
const { sign } = jwt;

const CURRENT_DOMAIN = import.meta.env.VITE_HOSTNAME;

export async function POST({ request }) {
	const { event } = await request.json();

	if (!event) {
		return json({ error: 'Missing event' }, { status: 400 });
	}

	const e = new NDKEvent(undefined, event);

	try {
		const jwt = await generateJWTFromEvent(e);
		return text(jwt);
	} catch (error: any) {
		console.log(error);
		return json({ error }, { status: 401 });
	}
}

async function generateJWTFromEvent(event: NDKEvent) {
	const pubkey = event.pubkey;
	let nwcAvailable = undefined;

	validateEvent(event);

	// check if user exists, else create it
	let user = await getUserFromPubkey(pubkey);
	console.log('user', user);

	if (!user) {
		// Create it
		console.log('Creating user');
		user = await createUser(pubkey);
		console.log('created user', user);
	} else {
		const nwcUri = await getWalletForPubkey(pubkey);

		nwcAvailable = !!nwcUri;
	}

	const jwtUser: Session = {
		pubkey: user.pubkey,
		nwcAvailable
	};

	return sign(jwtUser, JWT_ACCESS_SECRET);
}

function validateEvent(event: NDKEvent) {
	// validate signature
	if (!verifySignature(event.rawEvent() as Event<27235>)) {
		throw new Error('Invalid signature');
	}

	// validate date
	const now = Math.floor(Date.now() / 1000);
	const timeWindow = 3 * 60; // 3 minutes

	if (event.created_at! < now - timeWindow || event.created_at! > now + timeWindow) {
		// const dateString = new Date(event.created_at! * 1000).toISOString();
		// throw new Error('Invalid date, event has date ' + dateString);
	}

	// validate domain
	const domain = event.tagValue('domain');
	const currentDomain = CURRENT_DOMAIN;

	if (domain !== currentDomain) {
		throw new Error(`Invalid domain: received ${domain}, expected ${currentDomain}`);
	}
}
