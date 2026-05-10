<template>
  <section class="grid gap-6 lg:grid-cols-2">
    <div class="card bg-base-100 shadow-sm">
      <div class="card-body">
        <h2 class="card-title">{{ l("认证密钥", "Auth Secret") }}</h2>
        <p class="text-sm text-base-content/70">
          {{ l("系统会优先使用 `AUTH_SECRET` 或 `NEXTAUTH_SECRET`。未配置时会在 D1 中生成每个部署独有的登录密钥；生产环境仍建议使用 `wrangler secret put AUTH_SECRET` 手动配置。", "The system prefers `AUTH_SECRET` or `NEXTAUTH_SECRET`. If absent, it generates a per-install login secret in D1; production should still configure `AUTH_SECRET` with `wrangler secret put AUTH_SECRET`.") }}
        </p>
      </div>
    </div>

    <div class="card bg-base-100 shadow-sm">
      <div class="card-body">
        <h2 class="card-title">{{ l("登录限流", "Login Rate Limiting") }}</h2>
        <p class="text-sm text-base-content/70">
          {{ l("当前管理员登录已启用基础请求限流。你也应在 Cloudflare 后台为 `/api/auth/callback/credentials` 配置 Rate Limiting / WAF 规则。", "Admin login has basic request throttling enabled. You should also configure Cloudflare Rate Limiting / WAF rules for `/api/auth/callback/credentials`.") }}
        </p>
      </div>
    </div>

    <div class="card bg-base-100 shadow-sm">
      <div class="card-body">
        <h2 class="card-title">{{ l("密码安全", "Password Security") }}</h2>
        <p class="text-sm text-base-content/70">
          {{ l("请在首次初始化完成后，立即前往“个人资料”修改默认管理员密码，并定期轮换高权限账号口令。", "After initialization, change the default admin password in Profile and rotate privileged account passwords regularly.") }}
        </p>
        <AppButton :href="adminHref('/admin/profile')" variant="primary" size="sm">{{ l("前往个人资料", "Go to Profile") }}</AppButton>
      </div>
    </div>

    <div class="card bg-base-100 shadow-sm">
      <div class="card-body">
        <h2 class="card-title">{{ l("支付安全", "Payment Security") }}</h2>
        <p class="text-sm text-base-content/70">
          {{ l("支付日志会保留业务信息用于排查，但会对 `md5`、`key`、`secret`、`signature` 等敏感字段做脱敏处理。启用支付前，请先在“站点设置”配置网站地址。", "Payment logs keep business data for troubleshooting but mask sensitive fields such as `md5`, `key`, `secret`, and `signature`. Configure the site URL in Site Settings before enabling payments.") }}
        </p>
        <div class="flex gap-3">
          <AppButton :href="adminHref('/admin/settings')" variant="outline" size="sm">{{ l("站点设置", "Site Settings") }}</AppButton>
          <AppButton :href="adminHref('/admin/payments')" variant="primary" size="sm">{{ l("支付配置", "Payment Settings") }}</AppButton>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import AppButton from "../../../components/AppButton.vue";
import { useAdminPath } from "../../../lib/client-admin-path";
import { useI18n } from "../../../lib/client-i18n";

const { adminHref } = useAdminPath();
const { l } = useI18n();
</script>
