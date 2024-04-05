import { eq } from 'drizzle-orm';
import db from './db';
import { User, users } from './schema';

export async function getUserFromPubkey(pubkey: string): Promise<User | null> {
    const user = await db.select().from(users).where(eq(users.pubkey, pubkey)).limit(1);

    return user[0] ?? null;
}

export async function createUser(pubkey: string): Promise<User> {
    return await db.insert(users).values({ pubkey, createdAt: new Date(), updatedAt: new Date() }).run();
}