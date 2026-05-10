<template>
  <section class="card bg-base-100 shadow-sm">
    <div class="card-body space-y-4">
      <div class="flex items-center justify-between gap-4 max-md:flex-col max-md:items-start">
        <div>
          <h1 class="text-2xl font-bold">{{ l("商品管理", "Products") }}</h1>
          <p class="text-sm text-base-content/70">{{ l("管理商品价格、分类、上下架状态和购买限制。", "Manage product pricing, categories, status, and purchase limits.") }}</p>
        </div>
        <AppButton :href="adminHref('/admin/products/new')" variant="primary" size="sm">{{ l("新建商品", "New Product") }}</AppButton>
      </div>

      <div class="flex flex-wrap gap-3 items-center">
        <input v-model="filter.name" class="input input-sm input-bordered w-48" :placeholder="l('商品名称', 'Product Name')" />
        <select v-model="filter.status" class="select select-sm select-bordered w-32">
          <option value="">{{ l("全部状态", "All Statuses") }}</option>
          <option value="ACTIVE">{{ l("上架", "Active") }}</option>
          <option value="INACTIVE">{{ l("下架", "Inactive") }}</option><option value="DRAFT">{{ l("草稿", "Draft") }}</option>
        </select>
        <AppButton size="sm" variant="primary" @click="handleSearch">{{ l("搜索", "Search") }}</AppButton>
        <AppButton size="sm" variant="ghost" @click="handleReset">{{ l("重置", "Reset") }}</AppButton>
      </div>

      <DataTable
        :columns="columns"
        :rows="pageData.items"
        :total="pageData.total"
        :page="currentPage"
        :page-size="PAGE_SIZE"
        :empty-text="l('当前还没有商品，请先创建第一个商品。', 'No products yet. Create the first product.')"
        @update:page="fetchPage"
      >
        <template #name="{ row }">
          <div class="font-medium">{{ row.name }}</div>
          <div class="text-xs text-base-content/60">{{ row.slug }}</div>
        </template>
        <template #categoryName="{ value }">{{ value || l("未分类", "Uncategorized") }}</template>
        <template #price="{ value }">{{ formatCents(value) }}</template>
        <template #buy="{ row }">{{ row.minBuy }} - {{ row.maxBuy }}</template>
        <template #status="{ row }">
          <StatusTag :type="row.status === 'ACTIVE' ? 'success' : 'default'">
            {{ row.status === 'ACTIVE' ? l("上架", "Active") : row.status === 'DRAFT' ? l("草稿", "Draft") : l("下架", "Inactive") }}
          </StatusTag>
        </template>
        <template #actions="{ row }">
          <div class="flex gap-2">
            <AppButton :href="adminHref(`/admin/products/${row.id}/edit`)" variant="outline" size="xs">{{ l("编辑", "Edit") }}</AppButton>
            <AppButton size="xs" variant="danger" @click="handleDelete(row)">{{ l("删除", "Delete") }}</AppButton>
          </div>
        </template>
      </DataTable>
    </div>
  </section>
  <ConfirmDialog ref="confirmRef" />
</template>

<script setup lang="ts">
import { normalizeTelefuncError } from "../../../lib/app-error";
import { computed, ref, reactive, useTemplateRef } from "vue";
import AppButton from "../../../components/AppButton.vue";
import ConfirmDialog from "../../../components/ConfirmDialog.vue";
import DataTable from "../../../components/DataTable.vue";
import StatusTag from "../../../components/StatusTag.vue";
import { useData } from "vike-vue/useData";
import { formatCents } from "../../../lib/utils/money";
import { onDeleteProduct } from "./deleteProduct.telefunc";
import { onQueryProducts } from "./queryProducts.telefunc";
import { useAdminPath } from "../../../lib/client-admin-path";
import { useI18n } from "../../../lib/client-i18n";
import type { Data } from "./+data";

const { products, total } = useData<Data>();
const { adminHref } = useAdminPath();
const { l } = useI18n();

const PAGE_SIZE = 20;
const currentPage = ref(1);
const pageData = ref({ items: [...products], total });
const filter = reactive({ name: "", status: "" });
const confirmRef = useTemplateRef<InstanceType<typeof ConfirmDialog>>("confirmRef");

const columns = computed(() => [
  { key: "id", label: "ID" },
  { key: "name", label: l("商品", "Product") },
  { key: "categoryName", label: l("分类", "Category") },
  { key: "price", label: l("价格", "Price") },
  { key: "buy", label: l("限购", "Limit") },
  { key: "status", label: l("状态", "Status") },
  { key: "actions", label: l("操作", "Actions") },
]);

async function fetchPage(page: number) {
  pageData.value = await onQueryProducts({
    name: filter.name || undefined,
    status: filter.status || undefined,
    page,
    pageSize: PAGE_SIZE,
  });
  currentPage.value = page;
}

async function handleSearch() { await fetchPage(1); }

async function handleReset() {
  filter.name = "";
  filter.status = "";
  await fetchPage(1);
}

async function handleDelete(product: (typeof products)[number]) {
  if (!await confirmRef.value?.confirm({ title: l("删除商品", "Delete Product"), message: l(`确认删除商品"${product.name}"吗？`, `Delete product "${product.name}"?`), confirmText: l("删除", "Delete"), danger: true })) return;
  try {
    await onDeleteProduct({ id: product.id });
    await fetchPage(currentPage.value);
  } catch (error) {
    await confirmRef.value?.alert({ title: l("错误", "Error"), message: normalizeTelefuncError(error, l("删除失败", "Delete failed")) });
  }
}
</script>
