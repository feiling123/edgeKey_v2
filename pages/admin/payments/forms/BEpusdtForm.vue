<template>
  <div class="grid gap-4 md:grid-cols-2">
    <label class="flex flex-col gap-1.5">
      <span class="label-text font-medium">{{ l("商户 ID", "Merchant ID") }}</span>
      <input v-model="modelValue.merchantId" class="input input-bordered w-full" placeholder="default" />
    </label>
    <label class="flex flex-col gap-1.5">
      <span class="label-text font-medium">{{ l("支付币种", "Payment Currency") }}</span>
      <select v-model="modelValue.paymentType" class="select select-bordered w-full">
        <option v-for="item in paymentTypes" :key="item" :value="item">{{ item }}</option>
      </select>
    </label>
    <label class="flex flex-col gap-1.5">
      <span class="label-text font-medium">App Secret</span>
      <SecretInput v-model="modelValue.appSecret" />
    </label>
  </div>
</template>

<script setup lang="ts">
import SecretInput from "../../../../components/SecretInput.vue";
import { useI18n } from "../../../../lib/client-i18n";
defineProps<{ modelValue: Record<string, any> }>();
const { l } = useI18n();
const paymentTypes = [
  "USDT-TRC20",
  "TRX",
  "USDT-Polygon",
  "USDT-BSC",
  "USDT-ERC20",
  "USDT-ArbitrumOne",
  "USDC-ERC20",
  "USDC-Polygon",
  "USDC-BSC",
  "USDC-ArbitrumOne",
];
</script>
