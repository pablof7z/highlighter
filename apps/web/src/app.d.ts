// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces

import type { Hexpubkey, NDKUserParams } from "@nostr-dev-kit/ndk";

export type Session = {
	pubkey: string,
	nwcAvailable?: boolean,
}

export type NsecBunkerProvider = {
	pubkey: Hexpubkey,
	domain: string,
}

export type UserProfileType = NDKUserProfile & {
	categories: string[]?
};

export type EventType = "article" | "group-note" | "video";

declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface Platform {}
	}
}

export {};
