<template>
  <section class="card bg-base-100 shadow-sm">
    <div class="card-body space-y-4">
      <h1 class="text-2xl font-bold">{{ l("订单管理", "Order Management") }}</h1>

      <div class="flex flex-wrap gap-3 items-center">
        <input v-model="filter.orderNo" class="input input-sm input-bordered w-48" :placeholder="l('订单号', 'Order No.')" />
        <input v-model="filter.productName" class="input input-sm input-bordered w-40" :placeholder="l('商品名称', 'Product name')" />
        <select v-model="filter.paymentProvider" class="select select-sm select-bordered w-36">
          <option value="">{{ l("全部支付方式", "All payment methods") }}</option>
          <option value="EPAY">{{ l("易支付", "Epay") }}</option>
          <option value="ALIPAY">{{ l("支付宝", "Alipay") }}</option>
          <option value="BEPUSDT">BEpusdt</option>
        </select>
        <select v-model="filter.status" class="select select-sm select-bordered w-32">
          <option value="">{{ l("全部状态", "All statuses") }}</option>
          <option value="PENDING">{{ t("status.order.PENDING") }}</option>
          <option value="PAID">{{ t("status.order.PAID") }}</option>
          <option value="DELIVERED">{{ t("status.order.DELIVERED") }}</option>
          <option value="CLOSED">{{ t("status.order.CLOSED") }}</option><option value="FAILED">{{ t("status.order.FAILED") }}</option>
        </select>
        <input v-model="filter.startDate" type="date" class="input input-sm input-bordered w-40" />
        <input v-model="filter.endDate" type="date" class="input input-sm input-bordered w-40" />
        <AppButton size="sm" variant="primary" @click="handleSearch">{{ l("搜索", "Search") }}</AppButton>
        <AppButton size="sm" variant="ghost" @click="handleReset">{{ l("重置", "Reset") }}</AppButton>
      </div>

      <DataTable
        :columns="columns"
        :rows="orderPage.items"
        :total="orderPage.total"
        :page="currentPage"
        :page-size="PAGE_SIZE"
        @update:page="fetchPage"
      >
        <template #amount="{ value }">{{ formatCents(value) }}</template>
        <template #paymentProvider="{ value }">{{ getPaymentProviderDisplay(value) }}</template>
        <template #status="{ row }">
          <div class="flex flex-wrap gap-1">
            <StatusTag :type="getOrderStatusType(row.status)">{{ getOrderStatusDisplay(row.status) }}</StatusTag>
            <StatusTag :type="getPaymentStatusType(row.paymentStatus)">{{ getPaymentStatusDisplay(row.paymentStatus) }}</StatusTag>
            <StatusTag :type="getDeliveryStatusType(row.deliveryStatus)">{{ getDeliveryStatusDisplay(row.deliveryStatus) }}</StatusTag>
          </div>
        </template>
        <template #createdAt="{ value }">{{ formatDate(value) }}</template>
        <template #actions="{ row }">
          <AppButton :href="adminHref(`/admin/orders/${row.id}`)" size="xs" variant="outline">{{ l("详情", "Details") }}</AppButton>
        </template>
      </DataTable>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import AppButton from "../../../components/AppButton.vue";
import { useData } from "vike-vue/useData";
import DataTable from "../../../components/DataTable.vue";
import { formatCents } from "../../../lib/utils/money";
import { getDeliveryStatusType, getOrderStatusType, getPaymentStatusType } from "../../../lib/utils/order-status";
import StatusTag from "../../../components/StatusTag.vue";
import { onQueryOrders } from "./queryOrders.telefunc";
import { useAdminPath } from "../../../lib/client-admin-path";
import type { Data } from "./+data";
import { useI18n } from "../../../lib/client-i18n";

const { orders } = useData<Data>();
const { adminHref } = useAdminPath();
const { l, t, locale } = useI18n();

const PAGE_SIZE = 20;
const currentPage = ref(1);
const orderPage = ref(orders);

const filter = reactive({ orderNo: "", productName: "", paymentProvider: "", status: "", startDate: "", endDate: "" });

const columns = computed(() => [
  { key: "orderNo", label: l("订单号", "Order No.") },
  { key: "productName", label: l("商品", "Product") },
  { key: "amount", label: l("金额", "Amount") },
  { key: "paymentProvider", label: l("支付方式", "Payment") },
  { key: "status", label: l("状态", "Status") },
  { key: "createdAt", label: l("时间", "Time") },
  { key: "actions", label: l("操作", "Actions") },
]);

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

function getPaymentProviderDisplay(provider: string) {
  if (provider === "EPAY") return l("易支付", "Epay");
  if (provider === "ALIPAY") return l("支付宝", "Alipay");
  return provider;
}

async function fetchPage(page: number) {
  orderPage.value = await onQueryOrders({
    orderNo: filter.orderNo || undefined,
    productName: filter.productName || undefined,
    paymentProvider: filter.paymentProvider || undefined,
    status: filter.status || undefined,
    startDate: filter.startDate || undefined,
    endDate: filter.endDate || undefined,
    page,
    pageSize: PAGE_SIZE,
  });
  currentPage.value = page;
}

async function handleSearch() { await fetchPage(1); }

async function handleReset() {
  filter.orderNo = "";
  filter.productName = "";
  filter.paymentProvider = "";
  filter.status = "";
  filter.startDate = "";
  filter.endDate = "";
  await fetchPage(1);
}
</script>
