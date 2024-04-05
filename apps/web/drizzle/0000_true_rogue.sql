CREATE TABLE `payments` (
	`id` text PRIMARY KEY NOT NULL,
	`payer_pubkey` text,
	`zap_request` text,
	`zapped_event` text,
	`zap_endpoint` text,
	`receiver_pubkey` text,
	`sats_amount` integer,
	`tier_name` text,
	`valid_until` integer,
	`paid` integer DEFAULT false,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP,
	`updated_at` integer DEFAULT CURRENT_TIMESTAMP
);
--> statement-breakpoint
CREATE TABLE `stripe_sessions` (
	`id` text PRIMARY KEY NOT NULL,
	`payment_id` text,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP,
	`updated_at` integer DEFAULT CURRENT_TIMESTAMP,
	`paid` integer DEFAULT false,
	`amount` integer,
	`term` text,
	`currency` text,
	`tier_id` text,
	`subscriber_pubkey` text,
	`recipient_pubkey` text,
	`event` text
);
--> statement-breakpoint
CREATE TABLE `users` (
	`pubkey` text PRIMARY KEY NOT NULL,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP,
	`updated_at` integer DEFAULT CURRENT_TIMESTAMP
);
--> statement-breakpoint
CREATE TABLE `wallet_connects` (
	`pubkey` text PRIMARY KEY NOT NULL,
	`uri` text,
	`user_pubkey` text,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP,
	`updated_at` integer DEFAULT CURRENT_TIMESTAMP
);
