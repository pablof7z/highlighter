// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces

import type { Hexpubkey, NDKUserProfile } from '@nostr-dev-kit/ndk';
import type { SvelteComponent } from "svelte";

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
	created_at: number;
};

export type EventType =
	| 'article'
	| 'group-note'
	| 'group-reply'
	| 'video'
	| 'short-note'
	| 'highlight'
	| 'curation';

export interface UserUploadQuota {
	used: number;
	total: number;
}

export type NavigationOption = {
    value?: string;
    name: string;
    tooltip?: string;
    icon?: any;
	iconProps?: Record<string, any>;
    class?: string;
    href?: string;
	badge?: string | true;
    id?: string;
    component?: {
        component: typeof SvelteComponent;
        props?: Record<string, any>;
    }
    fn?: () => void;
    premiumOnly?: boolean;
};

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
