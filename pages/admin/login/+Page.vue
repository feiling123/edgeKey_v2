<template>
  <div class="flex min-h-screen items-center justify-center bg-base-200 px-4">
    <section class="card w-full max-w-md bg-base-100 shadow-sm">
      <div class="card-body space-y-4">
        <div>
          <p class="text-sm uppercase tracking-[0.2em] text-primary">EdgeKey Admin</p>
          <h1 class="text-2xl font-bold">{{ l("后台登录", "Admin Login") }}</h1>
        </div>
        <p class="text-sm text-base-content/70">
          {{ l("使用管理员账号登录后台，进行商品、库存、订单和支付配置管理。", "Sign in with an admin account to manage products, inventory, orders, and payment settings.") }}
        </p>
        <div v-if="errorMsg" class="alert alert-error text-sm">{{ errorMsg }}</div>
        <form class="space-y-4" method="post" :action="loginAction">
          <input type="hidden" name="csrfToken" :value="csrfToken" />
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ l("用户名", "Username") }}</span>
            <input name="username" class="input input-bordered w-full" placeholder="admin" required />
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ l("密码", "Password") }}</span>
            <input name="password" type="password" class="input input-bordered w-full" :placeholder="l('请输入密码', 'Enter password')" required />
          </label>
          <AppButton type="submit" variant="primary" :loading="loading" :disabled="!csrfToken" block>
            {{ l("登录后台", "Sign In") }}
          </AppButton>
        </form>
        <div class="rounded-box bg-base-200 p-3 text-xs text-base-content/70">
          {{ l("首次初始化完成后，请立即前往“个人资料”修改管理员密码。", "After first-time initialization, change the admin password in Profile immediately.") }}
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import AppButton from "../../../components/AppButton.vue";
import { usePageContext } from "vike-vue/usePageContext";
import { useI18n } from "../../../lib/client-i18n";

const csrfToken = ref("");
const loading = ref(true);
const errorMsg = ref("");
const pageContext = usePageContext();
const { l } = useI18n();
const adminBase = computed(() => pageContext.adminBase || "/admin");
const loginAction = computed(() => {
  if (typeof window === "undefined") {
    return `/api/auth/callback/credentials?callbackUrl=${encodeURIComponent(adminBase.value)}`;
  }
  const params = new URLSearchParams(location.search);
  const redirect = params.get("redirect") || adminBase.value;
  return `/api/auth/callback/credentials?callbackUrl=${encodeURIComponent(redirect)}`;
});

const ERROR_MAP: Record<string, () => string> = {
  CredentialsSignin: () => l("用户名或密码错误", "Invalid username or password"),
  password_upgrade_failed: () => l("登录成功但密码升级失败，请重置密码后重试", "Login succeeded but password upgrade failed. Reset the password and try again."),
};

onMounted(async () => {
  const params = new URLSearchParams(location.search);
  const code = params.get("code") ?? params.get("error");
  if (code) errorMsg.value = ERROR_MAP[code]?.() ?? l("登录失败，请重试", "Login failed, please try again");
  try {
    const response = await fetch("/api/auth/csrf", {
      credentials: "same-origin",
    });
    const data = (await response.json()) as { csrfToken?: string };
    csrfToken.value = data.csrfToken ?? "";
  } finally {
    loading.value = false;
  }
});
</script>
