/*
  Warnings:

  - You are about to drop the column `sessionId` on the `StripeSession` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "StripeSession" DROP COLUMN "sessionId",
ALTER COLUMN "paymentId" DROP NOT NULL;
