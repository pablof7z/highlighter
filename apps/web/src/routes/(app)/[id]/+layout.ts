import { NDKUser } from "@nostr-dev-kit/ndk";

export async function load({ params }) {
    const {id} = params;
    let user: NDKUser | undefined;

    if (id.startsWith('npub')) {
        user = new NDKUser({ npub: id });
        return { user, npub: id };
    }

    let npub = ``;

    try {
        user = await NDKUser.fromNip05(id);
        if (user) {
            npub = user.npub;
        }
    } catch(e) {
        console.log(e, ` error`);
    }

    if(!npub) {
        npub = id;
    }

    return {
        user, id,
        npub,
    };
}