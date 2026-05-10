-- CreateTable
CREATE TABLE "Admin" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "username" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "nickname" TEXT,
    "email" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "SiteSetting" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 1,
    "siteName" TEXT NOT NULL,
    "siteUrl" TEXT,
    "siteSubtitle" TEXT,
    "logoIcon" TEXT,
    "logo" TEXT,
    "notice" TEXT,
    "supportContact" TEXT,
    "footerText" TEXT,
    "orderNotice" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "Category" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "sort" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "Product" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "categoryId" INTEGER,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "coverImage" TEXT,
    "price" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'DRAFT',
    "deliveryType" TEXT NOT NULL DEFAULT 'CARD_AUTO',
    "stockMode" TEXT NOT NULL DEFAULT 'FINITE',
    "minBuy" INTEGER NOT NULL DEFAULT 1,
    "maxBuy" INTEGER NOT NULL DEFAULT 1,
    "sort" INTEGER NOT NULL DEFAULT 0,
    "isVisibleStock" BOOLEAN NOT NULL DEFAULT true,
    "isContactRequired" BOOLEAN NOT NULL DEFAULT true,
    "purchaseNote" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Product_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Card" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "productId" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'UNUSED',
    "batchNo" TEXT,
    "orderId" INTEGER,
    "soldAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Card_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Card_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Order" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "orderNo" TEXT NOT NULL,
    "queryToken" TEXT NOT NULL,
    "productId" INTEGER NOT NULL,
    "productNameSnapshot" TEXT NOT NULL,
    "unitPrice" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "contactType" TEXT NOT NULL DEFAULT 'EMAIL',
    "contactValue" TEXT,
    "buyerNote" TEXT,
    "paymentProvider" TEXT NOT NULL,
    "paymentChannel" TEXT,
    "paymentOrderNo" TEXT,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "paymentStatus" TEXT NOT NULL DEFAULT 'UNPAID',
    "deliveryStatus" TEXT NOT NULL DEFAULT 'NOT_DELIVERED',
    "paidAt" DATETIME,
    "deliveredAt" DATETIME,
    "closedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "Order_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "OrderDelivery" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "orderId" INTEGER NOT NULL,
    "deliveryType" TEXT NOT NULL DEFAULT 'CARD',
    "contentSnapshot" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'SUCCESS',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "OrderDelivery_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "PaymentConfig" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "provider" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "isEnabled" BOOLEAN NOT NULL DEFAULT false,
    "configJson" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "PaymentLog" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "orderId" INTEGER,
    "provider" TEXT NOT NULL,
    "orderNo" TEXT,
    "paymentOrderNo" TEXT,
    "eventType" TEXT NOT NULL,
    "rawPayload" TEXT NOT NULL,
    "verifyStatus" TEXT NOT NULL DEFAULT 'PENDING',
    "message" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PaymentLog_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "TelegramConfig" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "botToken" TEXT NOT NULL,
    "chatId" TEXT NOT NULL,
    "apiBaseUrl" TEXT NOT NULL DEFAULT 'https://api.telegram.org',
    "parseMode" TEXT NOT NULL DEFAULT 'NONE',
    "isEnabled" BOOLEAN NOT NULL DEFAULT false,
    "notifyOrderPaid" BOOLEAN NOT NULL DEFAULT true,
    "notifyDeliverySuccess" BOOLEAN NOT NULL DEFAULT true,
    "notifyDeliveryFailed" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "TelegramTemplate" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "scene" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "isEnabled" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "TelegramLog" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "orderId" INTEGER,
    "configId" INTEGER,
    "scene" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'SUCCESS',
    "chatId" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "telegramMessageId" TEXT,
    "error" TEXT,
    "triggeredBy" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "TelegramLog_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "TelegramLog_configId_fkey" FOREIGN KEY ("configId") REFERENCES "TelegramConfig" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "BlogCategory" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "slug" TEXT NOT NULL,
    "nameZh" TEXT NOT NULL,
    "nameEn" TEXT NOT NULL,
    "descriptionZh" TEXT,
    "descriptionEn" TEXT,
    "sort" INTEGER NOT NULL DEFAULT 0,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "BlogPost" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "categoryId" INTEGER,
    "slug" TEXT NOT NULL,
    "titleZh" TEXT NOT NULL,
    "titleEn" TEXT NOT NULL,
    "excerptZh" TEXT,
    "excerptEn" TEXT,
    "contentZh" TEXT NOT NULL,
    "contentEn" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'DRAFT',
    "readMinutes" INTEGER NOT NULL DEFAULT 3,
    "publishedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "BlogPost_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "BlogCategory" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "AdminOperationLog" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "adminId" INTEGER NOT NULL,
    "action" TEXT NOT NULL,
    "targetType" TEXT NOT NULL,
    "targetId" TEXT,
    "detail" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "AdminOperationLog_adminId_fkey" FOREIGN KEY ("adminId") REFERENCES "Admin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "Admin_username_key" ON "Admin"("username");

-- CreateIndex
CREATE UNIQUE INDEX "Category_slug_key" ON "Category"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "Product_slug_key" ON "Product"("slug");

-- CreateIndex
CREATE INDEX "Product_categoryId_idx" ON "Product"("categoryId");

-- CreateIndex
CREATE INDEX "Product_status_sort_idx" ON "Product"("status", "sort");

-- CreateIndex
CREATE INDEX "Card_productId_status_idx" ON "Card"("productId", "status");

-- CreateIndex
CREATE INDEX "Card_orderId_idx" ON "Card"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "Order_orderNo_key" ON "Order"("orderNo");

-- CreateIndex
CREATE INDEX "Order_productId_idx" ON "Order"("productId");

-- CreateIndex
CREATE INDEX "Order_status_createdAt_idx" ON "Order"("status", "createdAt");

-- CreateIndex
CREATE INDEX "Order_paymentStatus_createdAt_idx" ON "Order"("paymentStatus", "createdAt");

-- CreateIndex
CREATE INDEX "Order_deliveryStatus_createdAt_idx" ON "Order"("deliveryStatus", "createdAt");

-- CreateIndex
CREATE INDEX "OrderDelivery_orderId_createdAt_idx" ON "OrderDelivery"("orderId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "PaymentConfig_provider_key" ON "PaymentConfig"("provider");

-- CreateIndex
CREATE INDEX "PaymentLog_provider_createdAt_idx" ON "PaymentLog"("provider", "createdAt");

-- CreateIndex
CREATE INDEX "PaymentLog_orderNo_idx" ON "PaymentLog"("orderNo");

-- CreateIndex
CREATE INDEX "PaymentLog_orderId_idx" ON "PaymentLog"("orderId");

-- CreateIndex
CREATE INDEX "TelegramConfig_isEnabled_idx" ON "TelegramConfig"("isEnabled");

-- CreateIndex
CREATE UNIQUE INDEX "TelegramTemplate_scene_key" ON "TelegramTemplate"("scene");

-- CreateIndex
CREATE INDEX "TelegramLog_scene_createdAt_idx" ON "TelegramLog"("scene", "createdAt");

-- CreateIndex
CREATE INDEX "TelegramLog_status_createdAt_idx" ON "TelegramLog"("status", "createdAt");

-- CreateIndex
CREATE INDEX "TelegramLog_orderId_idx" ON "TelegramLog"("orderId");

-- CreateIndex
CREATE INDEX "TelegramLog_configId_createdAt_idx" ON "TelegramLog"("configId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "BlogCategory_slug_key" ON "BlogCategory"("slug");

-- CreateIndex
CREATE INDEX "BlogCategory_sort_idx" ON "BlogCategory"("sort");

-- CreateIndex
CREATE UNIQUE INDEX "BlogPost_slug_key" ON "BlogPost"("slug");

-- CreateIndex
CREATE INDEX "BlogPost_categoryId_idx" ON "BlogPost"("categoryId");

-- CreateIndex
CREATE INDEX "BlogPost_status_publishedAt_idx" ON "BlogPost"("status", "publishedAt");

-- CreateIndex
CREATE INDEX "AdminOperationLog_adminId_createdAt_idx" ON "AdminOperationLog"("adminId", "createdAt");
