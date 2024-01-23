// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces

import type { Hexpubkey, NDKUserProfile } from '@nostr-dev-kit/ndk';

export type TierEntry = {
	name?: string;
	selected: boolean;
};

export type Session = {
	pubkey: string;
	nwcAvailable?: boolean;
};

export type NsecBunkerProvider = {
	pubkey: Hexpubkey;
	domain: string;
};

export type UserProfileType = NDKUserProfile & {
	categories?: string[];
};

export type EventType =
	| 'article'
	| 'group-note'
	| 'video'
	| 'short-note'
	| 'highlight'
	| 'curation';

export interface UserUploadQuota {
	used: number;
	total: number;
}

declare global {
	namespace App {
		type FilterType = 'all' | EventType;
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface Platform {}
	}
}

export {};
