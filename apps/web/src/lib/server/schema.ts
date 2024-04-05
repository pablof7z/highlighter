import { InferModel, sql } from "drizzle-orm";
import { text, integer, sqliteTable } from "drizzle-orm/sqlite-core";

export const users = sqliteTable('users', {
    pubkey: text('pubkey').primaryKey(),
    createdAt: integer('created_at', { mode: 'timestamp' }).default(sql`CURRENT_TIMESTAMP`),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).default(sql`CURRENT_TIMESTAMP`),
});

export const walletConnects = sqliteTable('wallet_connects', {
    pubkey: text('pubkey').primaryKey(),
    uri: text('uri'),
    userPubkey: text('user_pubkey'),
    createdAt: integer('created_at', { mode: 'timestamp' }).default(sql`CURRENT_TIMESTAMP`),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).default(sql`CURRENT_TIMESTAMP`),
});

export const payments = sqliteTable('payments', {
    id: text('id').primaryKey(),
    payerPubkey: text('payer_pubkey'),
    zapRequest: text('zap_request'),
    zappedEvent: text('zapped_event'),
    zapEndpoint: text('zap_endpoint'),
    receiverPubkey: text('receiver_pubkey'),
    satsAmount: integer('sats_amount'),
    tierName: text('tier_name'),
    validUntil: integer('valid_until', { mode: 'timestamp' }),
    paid: integer('paid', { mode: 'boolean' }).default(false),
    createdAt: integer('created_at', { mode: 'timestamp' }).default(sql`CURRENT_TIMESTAMP`),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).default(sql`CURRENT_TIMESTAMP`),
});

export const stripeSessions = sqliteTable('stripe_sessions', {
    id: text('id').primaryKey(),
    paymentId: text('payment_id'),
    createdAt: integer('created_at', { mode: 'timestamp' }).default(sql`CURRENT_TIMESTAMP`),
    updatedAt: integer('updated_at', { mode: 'timestamp' }).default(sql`CURRENT_TIMESTAMP`),
    paid: integer('paid', { mode: 'boolean' }).default(false),
    amount: integer('amount'),
    term: text('term'),
    currency: text('currency'),
    tierId: text('tier_id'),
    subscriberPubkey: text('subscriber_pubkey'),
    recipientPubkey: text('recipient_pubkey'),
    event: text('event'),
});

export type User = InferModel<typeof users>;
export type WalletConnect = InferModel<typeof walletConnects>;
export type Payment = InferModel<typeof payments>;
export type StripeSession = InferModel<typeof stripeSessions>;