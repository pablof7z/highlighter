-- CreateTable
CREATE TABLE "User" (
    "pubkey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("pubkey")
);

-- CreateTable
CREATE TABLE "WalletConnect" (
    "id" TEXT NOT NULL,
    "uri" TEXT NOT NULL,
    "pubkey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "WalletConnect_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_pubkey_key" ON "User"("pubkey");

-- CreateIndex
CREATE UNIQUE INDEX "WalletConnect_id_key" ON "WalletConnect"("id");

-- AddForeignKey
ALTER TABLE "WalletConnect" ADD CONSTRAINT "WalletConnect_pubkey_fkey" FOREIGN KEY ("pubkey") REFERENCES "User"("pubkey") ON DELETE RESTRICT ON UPDATE CASCADE;
