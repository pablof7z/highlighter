-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL,
    "payerPubkey" TEXT NOT NULL,
    "zapRequest" TEXT NOT NULL,
    "receiverPubkey" TEXT NOT NULL,
    "tierName" TEXT,
    "validUntil" TIMESTAMP(3) NOT NULL,
    "paid" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);
