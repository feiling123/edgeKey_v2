<template>
  <ProductForm :title="l('新建商品', 'New Product')" :categories="categories" />
</template>

<script setup lang="ts">
import ProductForm from "../ProductForm.vue";
import { useData } from "vike-vue/useData";
import type { Data } from "./+data";
import { useI18n } from "../../../../lib/client-i18n";

const { categories } = useData<Data>();
const { l } = useI18n();
</script>
