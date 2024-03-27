/*
  Warnings:

  - You are about to drop the column `subscriptionStartEvent` on the `StripeSession` table. All the data in the column will be lost.
  - Added the required column `event` to the `StripeSession` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "StripeSession" DROP COLUMN "subscriptionStartEvent",
ADD COLUMN     "event" BYTEA NOT NULL;
