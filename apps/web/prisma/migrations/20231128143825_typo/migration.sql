/*
  Warnings:

  - You are about to drop the column `saatsAmount` on the `Payment` table. All the data in the column will be lost.
  - Added the required column `satsAmount` to the `Payment` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Payment" DROP COLUMN "saatsAmount",
ADD COLUMN     "satsAmount" INTEGER NOT NULL;
