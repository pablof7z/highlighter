/*
  Warnings:

  - A unique constraint covering the columns `[pubkey]` on the table `WalletConnect` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "WalletConnect_pubkey_key" ON "WalletConnect"("pubkey");
