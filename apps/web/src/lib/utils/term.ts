export const possibleTerms: Term[] = ['daily', 'weekly', 'monthly', 'quarterly', 'yearly'];

export type Term = 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly';

export function termToShort(term: Term): string {
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
