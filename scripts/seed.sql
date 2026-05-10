-- seed.sql
-- 此脚本由 deploy 脚本在每次部署时自动执行（bun run db:seed:remote）。
-- 所有语句均使用 ON CONFLICT DO NOTHING，即：记录不存在时插入初始数据，已存在时跳过。
-- 因此重复部署不会覆盖你在后台修改过的任何数据。

-- 管理员账号
INSERT INTO "Admin" ("username", "passwordHash", "nickname", "status", "updatedAt")
VALUES ('admin', '$2b$10$viMe8RgcpM30gmmF9OpOcuA/QgleSIUk5VRtqjOulfSIbgK5jQCI6', '管理员', 'ACTIVE', CURRENT_TIMESTAMP)
ON CONFLICT("username") DO NOTHING;

-- 站点设置
INSERT INTO "SiteSetting" ("id", "siteName", "siteSubtitle", "notice", "updatedAt")
VALUES (1, 'EK发卡商城', 'Cloudflare Workers 免费部署自动发卡商城', '全球部署，一触即达。', CURRENT_TIMESTAMP)
ON CONFLICT("id") DO NOTHING;

-- Telegram 通知模板
INSERT INTO "TelegramTemplate" ("scene", "name", "content", "isEnabled", "updatedAt")
VALUES
  ('TEST', '测试通知', 'Telegram 测试通知
  
站点：{{siteName}}
发送时间：{{sentAt}}

{{customContent}}', true, CURRENT_TIMESTAMP),
  ('ORDER_PAID', '收款成功通知', '收款成功通知

订单号：{{orderNo}}
商品：{{productName}}
金额：{{amount}}
查询地址：{{queryUrl}}', true, CURRENT_TIMESTAMP),
  ('DELIVERY_SUCCESS', '发货成功通知', '发货成功通知

订单号：{{orderNo}}
商品：{{productName}}
数量：{{quantity}}
发货内容：
{{deliveryItems}}

查询地址：{{queryUrl}}', true, CURRENT_TIMESTAMP),
  ('DELIVERY_FAILED', '发货失败告警', '发货失败告警

订单号：{{orderNo}}
商品：{{productName}}
失败原因：{{errorMessage}}

查询地址：{{queryUrl}}', true, CURRENT_TIMESTAMP)
ON CONFLICT("scene") DO NOTHING;
