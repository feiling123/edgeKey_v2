<template>
  <div v-if="!order" class="alert alert-warning">{{ t("order.missing") }}</div>
  <div v-else class="space-y-6">
    <section class="card bg-base-100 shadow-sm">
      <div class="card-body">
        <div class="flex items-start justify-between gap-4 max-md:flex-col">
          <div>
            <p class="text-sm uppercase tracking-[0.2em] text-primary">{{ t("order.label") }}</p>
            <h1 class="text-2xl font-bold">{{ order.orderNo }}</h1>
          </div>
          <div class="flex gap-2">
            <StatusTag :type="getOrderStatusType(order.status)">{{ orderStatusLabel(order.status) }}</StatusTag>
            <StatusTag :type="getPaymentStatusType(order.paymentStatus)">{{ paymentStatusLabel(order.paymentStatus) }}</StatusTag>
            <StatusTag :type="getDeliveryStatusType(order.deliveryStatus)">{{ deliveryStatusLabel(order.deliveryStatus) }}</StatusTag>
          </div>
        </div>
      </div>
    </section>

    <section class="grid gap-6 lg:grid-cols-2">
      <article class="card bg-base-100 shadow-sm">
        <div class="card-body">
          <h2 class="card-title">{{ t("order.info") }}</h2>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between"><span>{{ t("order.product") }}</span><span>{{ order.productName }}</span></div>
            <div class="flex justify-between"><span>{{ t("order.quantity") }}</span><span>{{ order.quantity }}</span></div>
            <div class="flex justify-between"><span>{{ t("order.amount") }}</span><span>{{ formatCents(order.amount) }}</span></div>
            <div class="flex justify-between"><span>{{ t("order.payment") }}</span><span>{{ getPaymentProviderLabel(order.paymentProvider) }}</span></div>
          </div>
          <div v-if="order.paymentStatus === 'UNPAID'" class="mt-4">
            <AppButton size="sm" variant="primary" :loading="paying" @click="handleContinuePay">{{ t("order.continue_pay") }}</AppButton>
            <p v-if="paymentError" class="mt-2 text-sm text-error">{{ paymentError }}</p>
          </div>
        </div>
      </article>

      <article class="card bg-base-100 shadow-sm">
        <div class="card-body">
          <h2 class="card-title">{{ t("order.delivery") }}</h2>
          <div v-if="order.deliveryContents.length" class="space-y-2">
            <pre v-for="content in order.deliveryContents" :key="content" class="rounded-box bg-base-200 p-3 text-sm">{{ content }}</pre>
          </div>
          <p v-else class="text-sm text-base-content/60">{{ t("order.delivery_empty") }}</p>
        </div>
      </article>
    </section>
  </div>
</template>

<script setup lang="ts">
import { normalizeTelefuncError } from "../../../lib/app-error";
import { ref, onMounted } from "vue";
import AppButton from "../../../components/AppButton.vue";
import { useData } from "vike-vue/useData";
import { formatCents } from "../../../lib/utils/money";
import { getDeliveryStatusType, getOrderStatusType, getPaymentProviderLabel, getPaymentStatusType } from "../../../lib/utils/order-status";
import StatusTag from "../../../components/StatusTag.vue";
import { onCreatePayment } from "./createPayment.telefunc";
import { onQueryAlipayPayment } from "./queryAlipayPayment.telefunc";
import { useI18n, t as translate } from "../../../lib/client-i18n";
import type { Data } from "./+data";

const { order } = useData<Data>();
const { t } = useI18n();
const paying = ref(false);
const paymentError = ref("");

onMounted(async () => {
  if (!order || order.paymentStatus !== "UNPAID" || order.paymentProvider !== "ALIPAY") return;
  const params = new URLSearchParams(window.location.search);
  if (!params.get("out_trade_no")) return;
  try {
    const result = await onQueryAlipayPayment({ orderNo: order.orderNo });
    if (result.isPaid || result.alreadyPaid) window.location.reload();
  } catch {}
});

async function handleContinuePay() {
  if (!order) return;

  paying.value = true;
  paymentError.value = "";

  try {
    const result = await onCreatePayment({ orderId: order.id });
    if (result.payUrl) {
      window.location.href = result.payUrl;
      return;
    }
    paymentError.value = t("order.no_pay_url");
  } catch (error) {
    paymentError.value = normalizeTelefuncError(error, t("order.pay_failed"));
  } finally {
    paying.value = false;
  }
}

function orderStatusLabel(status: string) {
  return translate(`status.order.${status}` as any);
}

function paymentStatusLabel(status: string) {
  return translate(`status.payment.${status}` as any);
}

function deliveryStatusLabel(status: string) {
  return translate(`status.delivery.${status}` as any);
}
</script>
