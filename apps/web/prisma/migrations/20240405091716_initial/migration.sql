-- CreateTable
CREATE TABLE "User" (
    "pubkey" TEXT NOT NULL PRIMARY KEY,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "WalletConnect" (
    "uri" TEXT NOT NULL,
    "pubkey" TEXT NOT NULL PRIMARY KEY,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "WalletConnect_pubkey_fkey" FOREIGN KEY ("pubkey") REFERENCES "User" ("pubkey") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "payerPubkey" TEXT NOT NULL,
    "zapRequest" TEXT NOT NULL,
    "zappedEvent" TEXT NOT NULL,
    "zapEndpoint" TEXT NOT NULL,
    "receiverPubkey" TEXT NOT NULL,
    "satsAmount" INTEGER NOT NULL,
    "tierName" TEXT,
    "validUntil" DATETIME NOT NULL,
    "paid" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "StripeSession" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "paymentId" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "paid" BOOLEAN NOT NULL DEFAULT false,
    "amount" INTEGER NOT NULL,
    "term" TEXT NOT NULL,
    "currency" TEXT NOT NULL,
    "tierId" TEXT,
    "subscriberPubkey" TEXT NOT NULL,
    "recipientPubkey" TEXT NOT NULL,
    "event" TEXT NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "User_pubkey_key" ON "User"("pubkey");
