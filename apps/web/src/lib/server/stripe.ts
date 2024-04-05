import db from "./db";
import { eq } from "drizzle-orm";
import { stripeSessions, StripeSession } from "./schema";

export async function getStripeSession(id: string): Promise<StripeSession | null> {
    const session = await db.select().from(stripeSessions).where(eq(stripeSessions.id, id)).limit(1);

    return session[0] ?? null;
}

export async function updateStripeSession(id: string, data: Partial<StripeSession>) {
    return await db.update(stripeSessions).set(data).where(eq(stripeSessions.id, id)).run();
}

export async function createStripeSession(data: Partial<StripeSession>) {
    return await db.insert(stripeSessions).values(data).run();
}