-- CreateEnum
CREATE TYPE "HostEarningStatus" AS ENUM ('PENDING', 'AVAILABLE', 'PAID', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PayoutStatus" AS ENUM ('NOT_READY', 'PROCESSING', 'PAID', 'FAILED');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "BookingStatus" ADD VALUE 'AWAITING_HOST';
ALTER TYPE "BookingStatus" ADD VALUE 'DECLINED';
ALTER TYPE "BookingStatus" ADD VALUE 'EXPIRED';

-- CreateTable
CREATE TABLE "host_earnings" (
    "id" UUID NOT NULL,
    "bookingId" UUID NOT NULL,
    "hostId" UUID NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'NGN',
    "status" "HostEarningStatus" NOT NULL DEFAULT 'PENDING',
    "availableAt" TIMESTAMP(3),
    "paidAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "host_earnings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payouts" (
    "id" UUID NOT NULL,
    "hostEarningId" UUID NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'MOCK',
    "providerReference" TEXT,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'NGN',
    "status" "PayoutStatus" NOT NULL DEFAULT 'NOT_READY',
    "failureReason" TEXT,
    "initiatedAt" TIMESTAMP(3),
    "paidAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payouts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "host_earnings_bookingId_key" ON "host_earnings"("bookingId");

-- CreateIndex
CREATE INDEX "host_earnings_hostId_idx" ON "host_earnings"("hostId");

-- CreateIndex
CREATE INDEX "host_earnings_status_idx" ON "host_earnings"("status");

-- CreateIndex
CREATE UNIQUE INDEX "payouts_providerReference_key" ON "payouts"("providerReference");

-- CreateIndex
CREATE INDEX "payouts_hostEarningId_idx" ON "payouts"("hostEarningId");

-- CreateIndex
CREATE INDEX "payouts_status_idx" ON "payouts"("status");

-- AddForeignKey
ALTER TABLE "host_earnings" ADD CONSTRAINT "host_earnings_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "bookings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "host_earnings" ADD CONSTRAINT "host_earnings_hostId_fkey" FOREIGN KEY ("hostId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payouts" ADD CONSTRAINT "payouts_hostEarningId_fkey" FOREIGN KEY ("hostEarningId") REFERENCES "host_earnings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
