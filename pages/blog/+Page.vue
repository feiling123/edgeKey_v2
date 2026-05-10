<template>
  <div>
    <section class="grid gap-6 lg:grid-cols-[260px_1fr]">
      <aside class="rounded-box border border-base-300 bg-base-100 p-4 shadow-sm lg:sticky lg:top-24 lg:self-start">
        <h2 class="px-2 text-sm font-semibold text-base-content/60">{{ t("blog.categories") }}</h2>
        <div class="mt-3 grid gap-2">
          <button class="btn justify-start" :class="activeCategory === null ? 'btn-primary' : 'btn-ghost'" @click="activeCategory = null">
            {{ t("blog.all_categories") }}
          </button>
          <button
            v-for="category in localizedCategories"
            :key="category.id"
            class="btn h-auto justify-start py-3 text-left"
            :class="activeCategory === category.id ? 'btn-primary' : 'btn-ghost'"
            @click="activeCategory = category.id"
          >
            <span>
              <span class="block font-semibold">{{ category.name }}</span>
              <span class="block text-xs opacity-70">{{ category.description }}</span>
            </span>
          </button>
        </div>
      </aside>

      <div class="space-y-4">
        <div class="flex items-center justify-between">
          <h2 class="text-2xl font-semibold">{{ t("blog.posts") }}</h2>
          <span class="text-sm text-base-content/50">{{ filteredPosts.length }}</span>
        </div>

        <article
          v-for="post in filteredPosts"
          :key="post.slug"
          class="rounded-box border border-base-300 bg-base-100 p-6 shadow-sm transition hover:-translate-y-0.5 hover:border-primary/30"
        >
          <div class="flex flex-wrap items-center gap-2 text-xs text-base-content/50">
            <span class="badge badge-outline">{{ categoryName(post.categoryId) }}</span>
            <time :datetime="post.date">{{ post.date }}</time>
            <span>{{ post.readMinutes }} min</span>
          </div>
          <h3 class="mt-3 text-2xl font-bold">
            <a :href="`/blog/${post.slug}`" class="hover:text-primary">{{ post.title }}</a>
          </h3>
          <p class="mt-3 text-base-content/70">{{ post.excerpt }}</p>
          <a class="btn btn-outline btn-sm mt-5" :href="`/blog/${post.slug}`">{{ t("blog.read_more") }}</a>
        </article>

        <div v-if="!filteredPosts.length" class="rounded-box border border-dashed border-base-300 bg-base-100 p-8 text-center text-base-content/60">
          {{ t("blog.empty") }}
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { useData } from "vike-vue/useData";
import { useI18n } from "../../lib/client-i18n";
import type { Data } from "./+data";

const { categories, posts } = useData<Data>();
const { locale, t } = useI18n();
const activeCategory = ref<string | null>(null);

const localizedCategories = computed(() => categories.map((category) => ({
  id: category.id,
  name: category.name[locale.value],
  description: category.description[locale.value],
})));

const localizedPosts = computed(() => posts.map((post) => ({
  ...post,
  title: post.title[locale.value],
  excerpt: post.excerpt[locale.value],
})));

const filteredPosts = computed(() => {
  if (!activeCategory.value) return localizedPosts.value;
  return localizedPosts.value.filter((post) => post.categoryId === activeCategory.value);
});

function categoryName(id: string) {
  return localizedCategories.value.find((category) => category.id === id)?.name || id;
}
</script>
