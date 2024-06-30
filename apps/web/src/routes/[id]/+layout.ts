import { getUserFromUrlId } from "$utils/user/from-url-id";

export async function load({ params }) {
    const { id } = params;

    console.log(`Loading user ${id}`);

    const { user } = await getUserFromUrlId(id);
    console.log("back from loading user", !!user)
    if (user?.pubkey) return { user, pubkey: user.pubkey };
}