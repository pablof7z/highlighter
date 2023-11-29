/*
  Warnings:

  - Added the required column `zappedEvent` to the `Payment` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Payment" ADD COLUMN     "zappedEvent" TEXT NOT NULL;
