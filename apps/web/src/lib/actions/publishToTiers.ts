import type NDK from '@nostr-dev-kit/ndk';
import type { NDKEvent, NDKRelaySet, NDKUser } from '@nostr-dev-kit/ndk';
import { getDefaultRelaySet } from '$utils/ndk';
import { requiredTiersFor, type TierSelection } from '$lib/events/tiers';
import { urlFromEvent } from '$utils/url';
import { dvmScheduleEvent } from '$lib/dvm';
import createDebug from "debug";

const debug = createDebug('HL:publishToTiers');

function addHTag(event: NDKEvent, user: NDKUser) {
	if (!event.tagValue('h')) {
		// Add NIP-29 group `h` tag
		event.tags.push(['h', user.pubkey]);
	}
}

function addTierTags(event: NDKEvent, tiers: TierSelection, teaser?: NDKEvent) {
	// Annotate the tiers
	for (const tier in tiers) {
		if (teaser) {
			if (tiers[tier].selected) {
				// If this tier is required, mark is such
				teaser.tag(['tier', tier]);
				console.log(`adding required tier ${tier} to teaser ${teaser.tagValue("title")}`)
			} else {
				// Otherwise, mark it for indexing
				teaser.tag(['f', tier]);
				console.log(`adding f tier ${tier} to teaser ${teaser.tagValue("title")}`)
			}
		}

		if (tiers[tier].selected) {
			event.tag(['f', tier]);
			console.log(`adding f tier ${tier} to event ${event.tagValue("title")}`)
		}
	}
}

async function addPubkeyAndDTag(event: NDKEvent, user: NDKUser, teaser?: NDKEvent) {
	// Add pubkey and `d` tags if appropriate
	event.pubkey = user.pubkey;
	if (event.isParamReplaceable() && !event.tagValue('d')) await event.generateTags();
	if (teaser) {
		teaser.pubkey = user.pubkey;
		if (teaser.isParamReplaceable() && !teaser.tagValue('d')) await teaser.generateTags();
	}
}

async function addPointerTags(event: NDKEvent, teaser?: NDKEvent) {
	if (teaser) {
		if (teaser.isParamReplaceable()) {
			event.tag(['preview', teaser.tagId()]);
		}

		if (event.isParamReplaceable()) {
			teaser.tag(['full', event.tagId()]);
		} else {
			await event.sign();
			teaser.tag(['full', event.tagId()]);
			teaser.tag(['url', urlFromEvent(event)]);
		}

		await teaser.sign();
	}
}

export async function prepareEventsForTierPublish(
	event: NDKEvent,
	tiers: TierSelection | undefined,
	opts: {
		teaserEvent?: NDKEvent;
		ndk?: NDK;
		relaySet?: NDKRelaySet;
		publishAt?: Date;
		skipHTag?: boolean;
		explicitCreatedAt?: number;
	} = {}
) {
	const ndk = opts.ndk ?? event.ndk!;
	const teaser = opts.teaserEvent;
	const publishAt = opts.publishAt ?? new Date();
	const user: NDKUser = await ndk.signer!.user();

	// remove signature
	event.sig = undefined;
	if (teaser) teaser.sig = undefined;

	// update created_at date
	console.log(`publishAt: ${publishAt}`);
	event.created_at = opts.explicitCreatedAt ?? Math.floor(publishAt.getTime() / 1000);
	if (teaser) teaser.created_at = opts.explicitCreatedAt ?? Math.floor(publishAt.getTime() / 1000);
	console.log(`event.created_at: ${event.created_at}`);

	if (!opts.skipHTag) addHTag(event, user);
	if (teaser) addHTag(teaser, user);

	if (tiers)
		addTierTags(event, tiers, teaser);

	await addPubkeyAndDTag(event, user, teaser);

	await addPointerTags(event, teaser);

	if (teaser) await teaser.sign();

	return [ event, teaser ];
}

async function publishOrSchedule(
	event: NDKEvent,
	relaySet: NDKRelaySet | undefined,
	publishAt?: Date,
) {
	if (!publishAt) {
		await event.publish(relaySet);
	} else {
		const relays = relaySet ? Array.from(relaySet.relays).map(r => r.url) : undefined;
		await dvmScheduleEvent(event, relays);
	}
}

export async function publishToTiers(
	event: NDKEvent,
	opts: {
		teaserEvent?: NDKEvent;
		ndk?: NDK;
		relaySet?: NDKRelaySet;
		publishAt?: Date;
	} = {}
) {
	const teaser = opts.teaserEvent;

	const eventHasFreeTier = requiredTiersFor(event).includes('Free');

	if (eventHasFreeTier) {
		opts.relaySet = undefined;
	} else {
		opts.relaySet = getDefaultRelaySet();
	}

	if (teaser) {
		await teaser.sign();

		debug("publishing teaser to relays", teaser.encode(), { requiredTiersFor: requiredTiersFor(teaser) } )

		await publishOrSchedule(teaser, undefined, opts.publishAt);
	}

	if (!event.sig) await event.sign();

	debug("publishing event to relays", event.rawEvent(), opts.relaySet)

	await publishOrSchedule(event, opts.relaySet, opts.publishAt);
}
