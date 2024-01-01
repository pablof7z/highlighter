// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces

import type { Hexpubkey } from "@nostr-dev-kit/ndk";

export type TierEntry = {
	name?: string,
	selected: boolean,
}

export type Session = {
	pubkey: string,
	nwcAvailable?: boolean,
}

export type NsecBunkerProvider = {
	pubkey: Hexpubkey,
	domain: string,
}

export type UserProfileType = NDKUserProfile & {
	categories: string[] | undefined;
};

export type EventType = "article" | "group-note" | "video";

declare global {
	namespace App {
		type EventType = "all" | "note" | "article" | "video";
		type FilterType = "all" | EventType;
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface Platform {}
	}
}

export {};
