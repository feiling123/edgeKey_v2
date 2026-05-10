<template>
  <div v-if="!post" class="alert alert-warning">{{ t("blog.not_found") }}</div>
  <article v-else class="mx-auto max-w-3xl space-y-6">
    <a href="/blog" class="btn btn-ghost btn-sm">← {{ t("blog.back") }}</a>

    <header class="rounded-box bg-base-100 p-8 shadow-sm">
      <div class="flex flex-wrap items-center gap-2 text-xs text-base-content/50">
        <span class="badge badge-outline">{{ categoryName(post.categoryId) }}</span>
        <time :datetime="post.date">{{ post.date }}</time>
        <span>{{ post.readMinutes }} min</span>
      </div>
      <h1 class="mt-4 text-3xl font-bold leading-tight md:text-5xl">{{ localizedPost.title }}</h1>
      <p class="mt-4 text-lg text-base-content/70">{{ localizedPost.excerpt }}</p>
    </header>

    <section class="rounded-box bg-base-100 p-8 shadow-sm">
      <div class="prose max-w-none text-base-content/80" v-html="localizedPost.contentHtml"></div>
    </section>

    <section v-if="localizedRelated.length" class="rounded-box border border-base-300 bg-base-100 p-6 shadow-sm">
      <h2 class="text-lg font-semibold">{{ t("blog.related") }}</h2>
      <div class="mt-4 grid gap-3">
        <a v-for="item in localizedRelated" :key="item.slug" :href="`/blog/${item.slug}`" class="rounded-box border border-base-200 p-4 hover:border-primary/30 hover:text-primary">
          {{ item.title }}
        </a>
      </div>
    </section>
  </article>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useData } from "vike-vue/useData";
import { useI18n } from "../../../lib/client-i18n";
import type { Data } from "./+data";

const { post, categories, related } = useData<Data>();
const { locale, t } = useI18n();

const localizedPost = computed(() => ({
  title: post?.title[locale.value] || "",
  excerpt: post?.excerpt[locale.value] || "",
  contentHtml: post?.contentHtml[locale.value] || "",
}));

const localizedRelated = computed(() => related.map((item) => ({
  slug: item.slug,
  title: item.title[locale.value],
})));

function categoryName(id: string) {
  const category = categories.find((item) => item.id === id);
  return category?.name[locale.value] || id;
}
</script>
