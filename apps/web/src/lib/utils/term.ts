import { calculateTermDurationInSeconds, type NDKIntervalFrequency } from "@nostr-dev-kit/ndk";

export const possibleTerms: NDKIntervalFrequency[] = ['daily', 'weekly', 'monthly', 'quarterly', 'yearly'];

export function termToShort(term: NDKIntervalFrequency): string {
	switch (term) {
		case 'daily':
			return 'day';
		case 'weekly':
			return 'week';
		case 'monthly':
			return 'mo';
		case 'quarterly':
			return 'quarter';
		case 'yearly':
			return 'year';
		default:
			return term;
	}
}

export function calculateEndOfTerm(
	term: NDKIntervalFrequency,
	startTime: Date,
): Date {
	const duration = calculateTermDurationInSeconds(term);

	return new Date(startTime.getTime() + duration * 1000);
}