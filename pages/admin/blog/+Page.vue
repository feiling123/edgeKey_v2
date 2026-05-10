<template>
  <section class="space-y-6">
    <div class="flex items-center justify-between gap-4 max-md:flex-col max-md:items-start">
      <div>
        <h1 class="text-2xl font-bold">{{ t("admin.blog.title") }}</h1>
        <p class="text-sm text-base-content/70">{{ t("admin.blog.subtitle") }}</p>
      </div>
      <div class="join">
        <button class="btn btn-sm join-item" :class="activeTab === 'posts' ? 'btn-primary' : 'btn-outline'" @click="activeTab = 'posts'">
          {{ t("admin.blog.posts") }}
        </button>
        <button class="btn btn-sm join-item" :class="activeTab === 'categories' ? 'btn-primary' : 'btn-outline'" @click="activeTab = 'categories'">
          {{ t("admin.blog.categories") }}
        </button>
      </div>
    </div>

    <section v-if="activeTab === 'posts'" class="grid gap-6 xl:grid-cols-[minmax(0,1.35fr)_minmax(360px,0.65fr)]">
      <div class="card bg-base-100 shadow-sm">
        <div class="card-body space-y-4">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold">{{ postForm.id ? t("admin.blog.edit_post") : t("admin.blog.new_post") }}</h2>
            <AppButton size="sm" variant="ghost" @click="resetPostForm">{{ t("common.reset") }}</AppButton>
          </div>

          <div class="grid gap-4 md:grid-cols-2">
            <label class="flex flex-col gap-1.5">
              <span class="label-text font-medium">{{ t("admin.blog.title_zh") }}</span>
              <input v-model="postForm.titleZh" class="input input-bordered w-full" />
            </label>
            <label class="flex flex-col gap-1.5">
              <span class="label-text font-medium">{{ t("admin.blog.title_en") }}</span>
              <input v-model="postForm.titleEn" class="input input-bordered w-full" />
            </label>
          </div>

          <div class="grid gap-4 md:grid-cols-4">
            <label class="flex flex-col gap-1.5 md:col-span-2">
              <span class="label-text font-medium">Slug</span>
              <input v-model="postForm.slug" class="input input-bordered w-full" :placeholder="t('admin.auto_slug')" />
            </label>
            <label class="flex flex-col gap-1.5">
              <span class="label-text font-medium">{{ t("admin.blog.category") }}</span>
              <select v-model="postForm.categoryId" class="select select-bordered w-full">
                <option value="">{{ t("admin.blog.no_category") }}</option>
                <option v-for="category in categoryList" :key="category.id" :value="String(category.id)">
                  {{ category.nameZh }} / {{ category.nameEn }}
                </option>
              </select>
            </label>
            <label class="flex flex-col gap-1.5">
              <span class="label-text font-medium">{{ t("admin.status") }}</span>
              <select v-model="postForm.status" class="select select-bordered w-full">
                <option value="ACTIVE">{{ t("admin.status.active") }}</option>
                <option value="INACTIVE">{{ t("admin.status.inactive") }}</option>
                <option value="DRAFT">{{ t("admin.status.draft") }}</option>
              </select>
            </label>
          </div>

          <div class="grid gap-4 md:grid-cols-2">
            <label class="flex flex-col gap-1.5">
              <span class="label-text font-medium">{{ t("admin.blog.date") }}</span>
              <input v-model="postForm.publishedAt" type="date" class="input input-bordered w-full" />
            </label>
            <label class="flex flex-col gap-1.5">
              <span class="label-text font-medium">{{ t("admin.blog.read_minutes") }}</span>
              <input v-model.number="postForm.readMinutes" type="number" min="1" max="60" class="input input-bordered w-full" />
            </label>
          </div>

          <div class="grid gap-4 md:grid-cols-2">
            <label class="flex flex-col gap-1.5">
              <span class="label-text font-medium">{{ t("admin.blog.excerpt_zh") }}</span>
              <textarea v-model="postForm.excerptZh" class="textarea textarea-bordered w-full" rows="3"></textarea>
            </label>
            <label class="flex flex-col gap-1.5">
              <span class="label-text font-medium">{{ t("admin.blog.excerpt_en") }}</span>
              <textarea v-model="postForm.excerptEn" class="textarea textarea-bordered w-full" rows="3"></textarea>
            </label>
          </div>

          <div class="space-y-3">
            <div class="join">
              <button class="btn btn-sm join-item" :class="contentLocale === 'zh' ? 'btn-primary' : 'btn-outline'" @click="contentLocale = 'zh'">{{ l("中文内容", "Chinese Content") }}</button>
              <button class="btn btn-sm join-item" :class="contentLocale === 'en' ? 'btn-primary' : 'btn-outline'" @click="contentLocale = 'en'">English Content</button>
            </div>
            <RichTextEditor v-if="contentLocale === 'zh'" v-model="postForm.contentZh" />
            <RichTextEditor v-else v-model="postForm.contentEn" />
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <AppButton variant="primary" :loading="savingPost" @click="handleSavePost">{{ t("admin.blog.save_post") }}</AppButton>
            <span v-if="postMessage" class="text-sm" :class="postMessageType === 'error' ? 'text-error' : 'text-success'">{{ postMessage }}</span>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 shadow-sm">
        <div class="card-body space-y-3">
          <h2 class="text-xl font-semibold">{{ t("admin.blog.post_list") }}</h2>
          <div v-if="!postList.length" class="rounded-box border border-dashed border-base-300 p-6 text-center text-base-content/60">
            {{ t("admin.blog.empty_posts") }}
          </div>
          <div v-else class="space-y-3">
            <article v-for="post in postList" :key="post.id" class="rounded-box border border-base-300 p-4">
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                  <div class="font-semibold">{{ post.titleZh }}</div>
                  <div class="truncate text-xs text-base-content/50">{{ post.slug }}</div>
                </div>
                <StatusTag :type="post.status === 'ACTIVE' ? 'success' : post.status === 'DRAFT' ? 'warning' : 'default'">
                  {{ statusLabel(post.status) }}
                </StatusTag>
              </div>
              <div class="mt-2 text-xs text-base-content/60">
              {{ post.categoryName || t("admin.blog.no_category") }} · {{ post.publishedAt }} · {{ post.readMinutes }} {{ l("分钟", "min") }}
              </div>
              <div class="mt-3 flex gap-2">
                <AppButton size="xs" variant="outline" @click="startEditPost(post)">{{ t("common.edit") }}</AppButton>
                <AppButton size="xs" variant="danger" @click="handleDeletePost(post)">{{ t("common.delete") }}</AppButton>
              </div>
            </article>
          </div>
        </div>
      </div>
    </section>

    <section v-else class="grid gap-6 lg:grid-cols-[minmax(320px,0.7fr)_minmax(0,1.3fr)]">
      <div class="card bg-base-100 shadow-sm">
        <div class="card-body space-y-4">
          <div class="flex items-center justify-between">
            <h2 class="text-xl font-semibold">{{ categoryForm.id ? t("admin.blog.edit_category") : t("admin.blog.new_category") }}</h2>
            <AppButton size="sm" variant="ghost" @click="resetCategoryForm">{{ t("common.reset") }}</AppButton>
          </div>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ t("admin.blog.category_zh") }}</span>
            <input v-model="categoryForm.nameZh" class="input input-bordered w-full" />
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ t("admin.blog.category_en") }}</span>
            <input v-model="categoryForm.nameEn" class="input input-bordered w-full" />
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">Slug</span>
            <input v-model="categoryForm.slug" class="input input-bordered w-full" :placeholder="t('admin.auto_slug')" />
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ t("admin.sort") }}</span>
            <input v-model.number="categoryForm.sort" type="number" class="input input-bordered w-full" />
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ t("admin.blog.description_zh") }}</span>
            <textarea v-model="categoryForm.descriptionZh" class="textarea textarea-bordered w-full" rows="3"></textarea>
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ t("admin.blog.description_en") }}</span>
            <textarea v-model="categoryForm.descriptionEn" class="textarea textarea-bordered w-full" rows="3"></textarea>
          </label>
          <div class="flex flex-wrap items-center gap-3">
            <AppButton variant="primary" :loading="savingCategory" @click="handleSaveCategory">{{ t("admin.blog.save_category") }}</AppButton>
            <span v-if="categoryMessage" class="text-sm" :class="categoryMessageType === 'error' ? 'text-error' : 'text-success'">{{ categoryMessage }}</span>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 shadow-sm">
        <div class="card-body">
          <DataTable
            :columns="categoryColumns"
            :rows="categoryList"
            :total="categoryList.length"
            :page="1"
            :page-size="categoryList.length || 1"
            :empty-text="t('admin.blog.empty_categories')"
          >
            <template #name="{ row }">
              <div class="font-medium">{{ row.nameZh }}</div>
              <div class="text-xs text-base-content/60">{{ row.nameEn }}</div>
            </template>
            <template #actions="{ row }">
              <div class="flex gap-2">
                <AppButton size="xs" variant="outline" @click="startEditCategory(row)">{{ t("common.edit") }}</AppButton>
                <AppButton size="xs" variant="danger" @click="handleDeleteCategory(row)">{{ t("common.delete") }}</AppButton>
              </div>
            </template>
          </DataTable>
        </div>
      </div>
    </section>
  </section>
  <ConfirmDialog ref="confirmRef" />
</template>

<script setup lang="ts">
import { computed, reactive, ref, useTemplateRef } from "vue";
import { useData } from "vike-vue/useData";
import AppButton from "../../../components/AppButton.vue";
import ConfirmDialog from "../../../components/ConfirmDialog.vue";
import DataTable from "../../../components/DataTable.vue";
import StatusTag from "../../../components/StatusTag.vue";
import { normalizeTelefuncError } from "../../../lib/app-error";
import { useI18n } from "../../../lib/client-i18n";
import RichTextEditor from "../products/RichTextEditor.vue";
import { onDeleteBlogCategory } from "./deleteBlogCategory.telefunc";
import { onDeleteBlogPost } from "./deleteBlogPost.telefunc";
import { onSaveBlogCategory } from "./saveBlogCategory.telefunc";
import { onSaveBlogPost } from "./saveBlogPost.telefunc";
import type { Data } from "./+data";

const { categories, posts } = useData<Data>();
const { l, t } = useI18n();
const confirmRef = useTemplateRef<InstanceType<typeof ConfirmDialog>>("confirmRef");

const activeTab = ref<"posts" | "categories">("posts");
const contentLocale = ref<"zh" | "en">("zh");
const categoryList = ref([...categories]);
const postList = ref([...posts]);
const savingCategory = ref(false);
const savingPost = ref(false);
const categoryMessage = ref("");
const postMessage = ref("");
const categoryMessageType = ref<"success" | "error">("success");
const postMessageType = ref<"success" | "error">("success");

const categoryColumns = computed(() => [
  { key: "id", label: "ID" },
  { key: "name", label: t("admin.blog.category") },
  { key: "slug", label: "Slug" },
  { key: "sort", label: t("admin.sort") },
  { key: "actions", label: t("admin.actions") },
]);

const categoryForm = reactive({
  id: undefined as number | undefined,
  slug: "",
  nameZh: "",
  nameEn: "",
  descriptionZh: "",
  descriptionEn: "",
  sort: 0,
});

const postForm = reactive({
  id: undefined as number | undefined,
  categoryId: "",
  slug: "",
  titleZh: "",
  titleEn: "",
  excerptZh: "",
  excerptEn: "",
  contentZh: "",
  contentEn: "",
  status: "DRAFT" as "DRAFT" | "ACTIVE" | "INACTIVE",
  readMinutes: 3,
  publishedAt: new Date().toISOString().slice(0, 10),
});

function resetCategoryForm() {
  Object.assign(categoryForm, {
    id: undefined,
    slug: "",
    nameZh: "",
    nameEn: "",
    descriptionZh: "",
    descriptionEn: "",
    sort: 0,
  });
  categoryMessage.value = "";
}

function resetPostForm() {
  Object.assign(postForm, {
    id: undefined,
    categoryId: "",
    slug: "",
    titleZh: "",
    titleEn: "",
    excerptZh: "",
    excerptEn: "",
    contentZh: "",
    contentEn: "",
    status: "DRAFT",
    readMinutes: 3,
    publishedAt: new Date().toISOString().slice(0, 10),
  });
  postMessage.value = "";
  contentLocale.value = "zh";
}

function startEditCategory(category: (typeof categoryList.value)[number]) {
  Object.assign(categoryForm, category);
  categoryMessage.value = "";
}

function startEditPost(post: (typeof postList.value)[number]) {
  Object.assign(postForm, {
    id: post.id,
    categoryId: post.categoryId ? String(post.categoryId) : "",
    slug: post.slug,
    titleZh: post.titleZh,
    titleEn: post.titleEn,
    excerptZh: post.excerptZh,
    excerptEn: post.excerptEn,
    contentZh: post.contentZh,
    contentEn: post.contentEn,
    status: post.status,
    readMinutes: post.readMinutes,
    publishedAt: post.publishedAt,
  });
  postMessage.value = "";
  contentLocale.value = "zh";
}

async function handleSaveCategory() {
  savingCategory.value = true;
  categoryMessage.value = "";

  try {
    const result = await onSaveBlogCategory({ ...categoryForm });
    const index = categoryList.value.findIndex((item) => item.id === result.id);
    if (index >= 0) categoryList.value[index] = result;
    else categoryList.value.unshift(result);
    categoryList.value = [...categoryList.value].sort((left, right) => left.sort - right.sort || left.id - right.id);
    categoryMessage.value = t("common.saved");
    categoryMessageType.value = "success";
    resetCategoryForm();
  } catch (error) {
    categoryMessage.value = normalizeTelefuncError(error, t("common.save_failed"));
    categoryMessageType.value = "error";
  } finally {
    savingCategory.value = false;
  }
}

async function handleSavePost() {
  savingPost.value = true;
  postMessage.value = "";

  try {
    const result = await onSaveBlogPost({
      id: postForm.id,
      categoryId: postForm.categoryId ? Number(postForm.categoryId) : null,
      slug: postForm.slug,
      titleZh: postForm.titleZh,
      titleEn: postForm.titleEn,
      excerptZh: postForm.excerptZh,
      excerptEn: postForm.excerptEn,
      contentZh: postForm.contentZh,
      contentEn: postForm.contentEn,
      status: postForm.status,
      readMinutes: postForm.readMinutes,
      publishedAt: postForm.publishedAt,
    });
    const index = postList.value.findIndex((item) => item.id === result.id);
    if (index >= 0) postList.value[index] = result;
    else postList.value.unshift(result);
    postMessage.value = t("common.saved");
    postMessageType.value = "success";
    resetPostForm();
  } catch (error) {
    postMessage.value = normalizeTelefuncError(error, t("common.save_failed"));
    postMessageType.value = "error";
  } finally {
    savingPost.value = false;
  }
}

async function handleDeleteCategory(category: (typeof categoryList.value)[number]) {
  const ok = await confirmRef.value?.confirm({
    title: t("admin.blog.delete_category"),
    message: t("admin.blog.delete_category_confirm", { name: category.nameZh }),
    confirmText: t("common.delete"),
    danger: true,
  });
  if (!ok) return;

  try {
    await onDeleteBlogCategory({ id: category.id });
    categoryList.value = categoryList.value.filter((item) => item.id !== category.id);
    postList.value = postList.value.map((post) => post.categoryId === category.id ? { ...post, categoryId: null, categoryName: null } : post);
    if (categoryForm.id === category.id) resetCategoryForm();
  } catch (error) {
    await confirmRef.value?.alert({ title: t("common.error"), message: normalizeTelefuncError(error, t("common.delete_failed")) });
  }
}

async function handleDeletePost(post: (typeof postList.value)[number]) {
  const ok = await confirmRef.value?.confirm({
    title: t("admin.blog.delete_post"),
    message: t("admin.blog.delete_post_confirm", { title: post.titleZh }),
    confirmText: t("common.delete"),
    danger: true,
  });
  if (!ok) return;

  try {
    await onDeleteBlogPost({ id: post.id });
    postList.value = postList.value.filter((item) => item.id !== post.id);
    if (postForm.id === post.id) resetPostForm();
  } catch (error) {
    await confirmRef.value?.alert({ title: t("common.error"), message: normalizeTelefuncError(error, t("common.delete_failed")) });
  }
}

function statusLabel(status: string) {
  if (status === "ACTIVE") return t("admin.status.active");
  if (status === "INACTIVE") return t("admin.status.inactive");
  return t("admin.status.draft");
}
</script>
