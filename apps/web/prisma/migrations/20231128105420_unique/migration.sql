/*
  Warnings:

  - The primary key for the `WalletConnect` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `WalletConnect` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "WalletConnect_id_key";

-- DropIndex
DROP INDEX "WalletConnect_pubkey_key";

-- AlterTable
ALTER TABLE "WalletConnect" DROP CONSTRAINT "WalletConnect_pkey",
DROP COLUMN "id",
ADD CONSTRAINT "WalletConnect_pkey" PRIMARY KEY ("pubkey");
