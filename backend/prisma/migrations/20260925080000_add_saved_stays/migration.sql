-- CreateTable
CREATE TABLE "saved_stays" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "propertyId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "saved_stays_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "saved_stays_userId_propertyId_key" ON "saved_stays"("userId", "propertyId");

-- CreateIndex
CREATE INDEX "saved_stays_userId_idx" ON "saved_stays"("userId");

-- CreateIndex
CREATE INDEX "saved_stays_propertyId_idx" ON "saved_stays"("propertyId");

-- AddForeignKey
ALTER TABLE "saved_stays" ADD CONSTRAINT "saved_stays_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_stays" ADD CONSTRAINT "saved_stays_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE;
