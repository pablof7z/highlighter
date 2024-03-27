/*
  Warnings:

  - Added the required column `currency` to the `StripeSession` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "StripeSession" ADD COLUMN     "currency" TEXT NOT NULL;
