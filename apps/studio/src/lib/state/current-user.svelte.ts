import type { NDKUser } from "@nostr-dev-kit/ndk-svelte";
import { ndk } from "./ndk";

let user = $state<NDKUser | null>(null);

export const setCurrentUser = (u: NDKUser | null) => {
	user = u;
};

ndk.on('signer:ready', (signer) => {
    if (signer) {
		signer.user().then((user) => {
			setCurrentUser(user);
		});
	}
});

export const currentUser = () => user;