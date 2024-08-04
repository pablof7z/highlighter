import { getUserFromUrlId } from "$utils/user/from-url-id";

export async function load({ params }) {
    const { id } = params;

    const { user } = await getUserFromUrlId(id);
    if (user?.pubkey) return { user, pubkey: user.pubkey };
}