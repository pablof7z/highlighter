import type { NDKEvent } from '@nostr-dev-kit/ndk';

export function calculateValidUntil(event: NDKEvent): Date {
	const amountTag = event.getMatchingTags('amount')[0];
	const cadennce = amountTag[3];
	const now = new Date();

	if (cadennce === 'monthly') {
		now.setMonth(now.getMonth() + 1);
	} else if (cadennce === 'yearly') {
		now.setFullYear(now.getFullYear() + 1);
	} else if (cadennce === 'quarterly') {
		now.setMonth(now.getMonth() + 3);
	} else if (cadennce === 'weekly') {
		now.setDate(now.getDate() + 7);
	} else if (cadennce === 'daily') {
		now.setDate(now.getDate() + 1);
	} else {
		throw new Error('Cadence not supported');
	}

	return now;
}
