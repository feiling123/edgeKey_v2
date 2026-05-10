<template>
  <section v-if="!order" class="alert alert-warning">{{ l("订单不存在。", "Order does not exist.") }}</section>
  <section v-else class="space-y-6">
    <article class="card bg-base-100 shadow-sm">
      <div class="card-body space-y-3">
        <div class="flex items-center justify-between gap-4 max-md:flex-col max-md:items-start">
          <div>
            <h1 class="text-2xl font-bold">{{ l("订单详情", "Order Detail") }} #{{ order.id }}</h1>
            <p class="text-sm text-base-content/70">{{ l("订单号", "Order No.") }}: {{ order.orderNo }}</p>
          </div>
          <div class="flex flex-wrap gap-2">
            <StatusTag :type="getOrderStatusType(order.status)">{{ getOrderStatusDisplay(order.status) }}</StatusTag>
            <StatusTag :type="getPaymentStatusType(order.paymentStatus)">{{ getPaymentStatusDisplay(order.paymentStatus) }}</StatusTag>
            <StatusTag :type="getDeliveryStatusType(order.deliveryStatus)">{{ getDeliveryStatusDisplay(order.deliveryStatus) }}</StatusTag>
          </div>
        </div>
        <div class="grid gap-4 md:grid-cols-2">
          <div class="space-y-1 text-sm">
            <div>{{ l("商品", "Product") }}: {{ order.productName }}</div>
            <div>{{ l("数量", "Quantity") }}: {{ order.quantity }}</div>
            <div>{{ l("金额", "Amount") }}: {{ formatCents(order.amount) }}</div>
            <div>{{ l("支付方式", "Payment Method") }}: {{ getPaymentProviderDisplay(order.paymentProvider) }}</div>
          </div>
          <div class="space-y-1 text-sm">
            <div>{{ l("联系方式", "Contact") }}: {{ order.contactValue || '-' }}</div>
            <div>{{ l("备注", "Note") }}: {{ order.buyerNote || '-' }}</div>
            <div>{{ l("创建时间", "Created At") }}: {{ formatDate(order.createdAt) }}</div>
            <div>{{ l("查询凭证", "Query Token") }}: <code>{{ order.queryToken }}</code></div>
          </div>
        </div>
        <div class="flex flex-wrap items-center gap-3 pt-2">
          <AppButton size="sm" variant="primary" :disabled="order.deliveryStatus === 'DELIVERED' || order.paymentStatus !== 'PAID'" @click="handleRedeliver">{{ l("手动补发", "Redeliver") }}</AppButton>
          <AppButton size="sm" variant="outline" :disabled="order.status === 'CLOSED'" @click="handleClose">{{ l("关闭订单", "Close Order") }}</AppButton>
          <span v-if="actionMessage" class="text-sm text-success">{{ actionMessage }}</span>
          <span v-if="actionError" class="text-sm text-error">{{ actionError }}</span>
        </div>
      </div>
    </article>

    <article class="card bg-base-100 shadow-sm">
      <div class="card-body">
        <h2 class="card-title">{{ l("发货记录", "Delivery Records") }}</h2>
        <div v-if="order.deliveries.length" class="space-y-3">
          <div v-for="item in order.deliveries" :key="item.id" class="rounded-box bg-base-200 p-3 text-sm">
            <div>{{ item.contentSnapshot }}</div>
            <div class="mt-1 text-xs text-base-content/60">{{ formatDate(item.createdAt) }}</div>
          </div>
        </div>
        <p v-else class="text-sm text-base-content/60">{{ l("暂无发货记录。", "No delivery records.") }}</p>
      </div>
    </article>

    <article class="card bg-base-100 shadow-sm">
      <div class="card-body">
        <h2 class="card-title">{{ l("支付日志", "Payment Logs") }}</h2>
        <div v-if="order.paymentLogs.length" class="space-y-3 max-h-96 overflow-y-auto">
          <div v-for="log in order.paymentLogs" :key="log.id" class="rounded-box bg-base-200 p-3 text-sm">
            <div class="flex items-center justify-between gap-2">
              <div class="font-medium">{{ log.eventType }}</div>
              <button v-if="log.rawPayload" class="btn btn-xs btn-ghost" @click="openRawPayload(log.rawPayload)">{{ l("详情", "Details") }}</button>
            </div>
            <div class="text-xs text-base-content/60">{{ getVerifyStatusDisplay(log.verifyStatus) }} · {{ formatDate(log.createdAt) }}</div>
            <div v-if="log.message" class="mt-1">{{ log.message }}</div>
          </div>
        </div>
        <p v-else class="text-sm text-base-content/60">{{ l("暂无支付日志。", "No payment logs.") }}</p>

        <dialog ref="payloadDialogRef" class="modal">
          <div class="modal-box max-w-2xl">
            <h3 class="font-bold text-lg mb-3">{{ l("原始 Payload", "Raw Payload") }}</h3>
            <pre class="bg-base-200 rounded-box p-3 text-xs overflow-x-auto whitespace-pre-wrap break-all">{{ formattedPayload }}</pre>
            <div class="modal-action">
              <form method="dialog"><button class="btn btn-sm">{{ l("关闭", "Close") }}</button></form>
            </div></div>
          <form method="dialog" class="modal-backdrop"><button>{{ l("关闭", "Close") }}</button></form>
        </dialog>
      </div>
    </article>
  </section>
</template>

<script setup lang="ts">
import { normalizeTelefuncError } from "../../../../lib/app-error";
import { ref } from "vue";
import { useData } from "vike-vue/useData";
import { formatCents } from "../../../../lib/utils/money";
import {
  getDeliveryStatusType,
  getOrderStatusType,
  getPaymentStatusType,
} from "../../../../lib/utils/order-status";
import StatusTag from "../../../../components/StatusTag.vue";
import AppButton from "../../../../components/AppButton.vue";
import { onCloseOrder } from "./closeOrder.telefunc";
import { onRedeliver } from "./redeliver.telefunc";
import type { Data } from "./+data";
import { useI18n } from "../../../../lib/client-i18n";

const { order } = useData<Data>();
const { l, t, locale } = useI18n();
const actionMessage = ref("");
const actionError = ref("");
const payloadDialogRef = ref<HTMLDialogElement | null>(null);
const formattedPayload = ref("");

function openRawPayload(raw: string) {
  try {
    formattedPayload.value = JSON.stringify(JSON.parse(raw), null, 2);
  } catch {
    formattedPayload.value = raw;
  }
  payloadDialogRef.value?.showModal();
}

function formatDate(value: string) {
  return new Date(value).toLocaleString(locale.value === "zh" ? "zh-CN" : "en-US");
}

function getOrderStatusDisplay(status: string) {
  return t(`status.order.${status}` as any);
}

function getPaymentStatusDisplay(status: string) {
  return t(`status.payment.${status}` as any);
}

function getDeliveryStatusDisplay(status: string) {
  return t(`status.delivery.${status}` as any);
}

function getVerifyStatusDisplay(status: string) {
  if (status === "PENDING") return l("待校验", "Pending Verification");
  if (status === "VERIFIED") return l("已校验", "Verified");
  if (status === "FAILED") return l("校验失败", "Verification Failed");
  return status;
}

function getPaymentProviderDisplay(provider: string) {
  if (provider === "EPAY") return l("易支付", "Epay");
  if (provider === "ALIPAY") return l("支付宝", "Alipay");
  return provider;
}

async function handleRedeliver() {
  if (!order) return;
  actionMessage.value = "";
  actionError.value = "";

  try {
    const result = await onRedeliver({ orderId: order.id });
    actionMessage.value = l(`补发完成，共发出 ${result.items.length} 条卡密。`, `Redelivery completed. ${result.items.length} card(s) sent.`);
  } catch (error) {
    actionError.value = normalizeTelefuncError(error, l("补发失败", "Redelivery failed"));
  }
}

async function handleClose() {
  if (!order) return;
  actionMessage.value = "";
  actionError.value = "";

  try {
    await onCloseOrder({ orderId: order.id });
    actionMessage.value = l("订单已关闭，请刷新查看最新状态。", "Order closed. Refresh to see the latest status.");
  } catch (error) {
    actionError.value = normalizeTelefuncError(error, l("关闭失败", "Close failed"));
  }
}
</script>
