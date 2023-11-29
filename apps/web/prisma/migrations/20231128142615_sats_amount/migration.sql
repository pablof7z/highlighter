/*
  Warnings:

  - Added the required column `saatsAmount` to the `Payment` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Payment" ADD COLUMN     "saatsAmount" INTEGER NOT NULL;
