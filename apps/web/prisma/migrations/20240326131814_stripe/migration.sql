-- CreateTable
CREATE TABLE "StripeSession" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "paymentId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "paid" BOOLEAN NOT NULL DEFAULT false,
    "amount" INTEGER NOT NULL,
    "term" TEXT NOT NULL,
    "tierId" TEXT,
    "subscriberPubkey" TEXT NOT NULL,
    "recipientPubkey" TEXT NOT NULL,

    CONSTRAINT "StripeSession_pkey" PRIMARY KEY ("id")
);
