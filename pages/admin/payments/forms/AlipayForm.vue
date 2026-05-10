<template>
  <div class="space-y-4">
    <div class="grid gap-4 md:grid-cols-2">
      <label class="flex flex-col gap-1.5">
        <span class="label-text font-medium">App ID</span>
        <input v-model="modelValue.alipayAppId" class="input input-bordered w-full" :placeholder="l('支付宝开放平台应用 ID', 'Alipay Open Platform App ID')" />
      </label>
    </div>
    <label class="flex flex-col gap-1.5">
      <span class="label-text font-medium">{{ l("应用私钥（PKCS#8，去掉头尾和换行）", "App Private Key (PKCS#8, without header/footer/newlines)") }}</span>
      <SecretInput v-model="modelValue.alipayPrivateKey" placeholder="MIIEvgIBADANBgkq..." />
    </label>
    <label class="flex flex-col gap-1.5">
      <span class="label-text font-medium">{{ l("支付宝公钥（用于验签，去掉头尾和换行）", "Alipay Public Key (for signature verification, without header/footer/newlines)") }}</span>
      <SecretInput v-model="modelValue.alipayPublicKey" placeholder="MIIBIjANBgkq..." />
    </label>
    <p class="text-xs text-base-content/60">{{ l("密钥生成工具：", "Key generator: ") }}<a href="https://opendocs.alipay.com/common/02kipl" target="_blank" class="link">{{ l("支付宝密钥工具", "Alipay Key Tool") }}</a></p>
  </div>
</template>

<script setup lang="ts">
import SecretInput from "../../../../components/SecretInput.vue";
import { useI18n } from "../../../../lib/client-i18n";
defineProps<{ modelValue: Record<string, any> }>();
const { l } = useI18n();
</script>
