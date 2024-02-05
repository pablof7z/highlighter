import NDK, { NDKEvent, NDKUser, type NDKIntervalFrequency, type NostrEvent, NDKSubscriptionStart, NDKSubscriptionTier } from '@nostr-dev-kit/ndk';

export async function createSubscriptionEvent(
	ndk: NDK,
	amount: string,
	currency: string,
	term: NDKIntervalFrequency,
	supportedUser?: NDKUser,
	tier?: NDKSubscriptionTier,
) {
	const supportEvent = new NDKSubscriptionStart(ndk, {
		tags: [['amount', amount, currency, term]]
	} as NostrEvent);
	supportEvent.amount = {
		amount: parseFloat(amount),
		currency,
		term
	};
	supportEvent.tier = tier;

	if (!tier) {
		supportEvent.tag(supportedUser!);
	}

	await supportEvent.sign();
	return supportEvent;
}
