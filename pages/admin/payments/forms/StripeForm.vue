<template>
  <div class="space-y-4">
    <label class="flex flex-col gap-1.5">
      <span class="label-text font-medium">Secret Key</span>
      <SecretInput v-model="modelValue.stripeSecretKey" placeholder="sk_live_..." />
    </label>
    <label class="flex flex-col gap-1.5">
      <span class="label-text font-medium">Webhook Secret</span>
      <SecretInput v-model="modelValue.stripeWebhookSecret" placeholder="whsec_..." />
      <p class="text-xs text-base-content/60">
        {{ l("在", "Get API keys in") }} <a href="https://dashboard.stripe.com/apikeys" target="_blank" class="link">Stripe Dashboard</a>{{ l(" 获取 API 密钥，Webhook Secret 在", ", and get the Webhook Secret after creating an endpoint in") }} <a href="https://dashboard.stripe.com/webhooks" target="_blank" class="link">Webhooks</a>{{ l(" 页面创建端点后获取。回调事件请选择", ". Select callback event") }} <code>checkout.session.completed</code>.
      </p>
    </label>
    <label class="flex flex-col gap-1.5">
      <span class="label-text font-medium">{{ l("货币代码", "Currency Code") }}</span>
      <input v-model="modelValue.stripeCurrency" class="input input-bordered w-full" placeholder="cny" />
      <p class="text-xs text-base-content/60">{{ l("ISO 4217 货币代码，如 cny、usd、hkd，默认 cny", "ISO 4217 currency code, such as cny, usd, or hkd. Default: cny") }}</p>
    </label>
  </div>
</template>

<script setup lang="ts">
import SecretInput from "../../../../components/SecretInput.vue";
import { useI18n } from "../../../../lib/client-i18n";
defineProps<{ modelValue: Record<string, any> }>();
const { l } = useI18n();
</script>
