import { NDKUser } from "@nostr-dev-kit/ndk";

export async function load({ params }) {
    const {id} = params;

    if (id.startsWith('npub')) {
        return { npub: id };
    }

    let npub = ``;

    try {
        const user = await NDKUser.fromNip05(id);
        if(user) {
            npub = user.npub;
        }
    } catch(e) {
        console.log(e, ` error`);
    }

    if(!npub) {
        npub = id;
    }

    return {
        npub,
    };
}