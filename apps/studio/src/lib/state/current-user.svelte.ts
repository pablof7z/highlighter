import type { NDKEvent, NDKFilter, NDKUser } from "@nostr-dev-kit/ndk";
import { ndk } from "./ndk";
import { NDKKind, profileFromEvent, type Hexpubkey, type NDKUserProfile } from "@nostr-dev-kit/ndk";
import { Profile } from "@/components/user/profile.svelte";

let user = $state<NDKUser | null>(null);

let userFollowsEvent = $state<NDKEvent | null>(null);
let blossomListEvent = $state<NDKEvent | null>(null);

let userProfile = $state<Profile | null>(null);

const userFollows = $derived.by<Set<Hexpubkey>>(() => {
	if (!userFollowsEvent) return new Set();
	return new Set(userFollowsEvent.getMatchingTags("p").map(([_, pubkey]) => pubkey));
})

const blossomServers = $derived.by(() => {
	if (!blossomListEvent) return [];
	return blossomListEvent.getMatchingTags("server").map(([_, server]) => server);
})

ndk.on('signer:ready', async (signer) => {
	console.log("signer:ready");
	if (signer) {
		user = await signer.user();
		userProfile = new Profile(user);

		const filters: NDKFilter[] = [
			{ kinds: [NDKKind.Contacts, NDKKind.BlossomList ], authors: [user.pubkey] }
		]

		console.log(filters);

		const sub = ndk.subscribe(filters, { groupable: false }, undefined, false);
		sub.on('event', (event) => {
			switch (event.kind) {
				case NDKKind.Contacts:
					if (!userFollowsEvent || event.created_at! > userFollowsEvent.created_at!) {
						userFollowsEvent = event;
					}
					break;
				case NDKKind.BlossomList:
					if (!blossomListEvent || event.created_at! > blossomListEvent.created_at!) {
						blossomListEvent = event;
					}
					break;
			}
		})

		sub.start();
	}
});

export const currentUser = (): NDKUser | null => user;
export const currentUserProfile = (): Profile | null => userProfile;
export const currentUserFollows = (): Set<Hexpubkey> => userFollows;
export const currentUserBlossomServers = (): string[] => blossomServers;
