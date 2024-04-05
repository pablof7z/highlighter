import { walletConnects } from "./schema";
import db from "./db";
import { eq } from "drizzle-orm";

export async function getWalletForPubkey(pubkey: string): Promise<string | null> {
    const wallet = await db.select().from(walletConnects).where(eq(walletConnects.pubkey, pubkey)).limit(1);

    return wallet[0]?.uri ?? null;
}

export async function setWalletForPubkey(pubkey: string, uri: string) {
    await db.insert(walletConnects).values({ pubkey, uri }).onConflictDoUpdate({
        target: walletConnects.pubkey,
        set: { uri }
    });
}