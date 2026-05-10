<template>
  <div class="min-h-screen flex items-center justify-center bg-base-200 px-4">
    <div class="text-center space-y-4">
      <div class="text-8xl font-black text-base-content/10">{{ is404 ? '404' : '500' }}</div>
      <h1 class="text-2xl font-bold text-base-content">{{ heading }}</h1>
      <p class="text-base-content/60">{{ message }}</p>
      <AppButton href="/" variant="primary">{{ l("返回首页", "Back Home") }}</AppButton>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { usePageContext } from "vike-vue/usePageContext";
import AppButton from "../../components/AppButton.vue";
import { useI18n } from "../../lib/client-i18n";

const pageContext = usePageContext();
const { l } = useI18n();
const { is404, abortReason } = pageContext;
const heading = is404 ? l("页面不存在", "Page Not Found") : l("服务器错误", "Server Error");
const message = abortReason ?? (is404 ? l("你访问的页面不存在或已被删除。", "The page you visited does not exist or has been removed.") : l("服务器发生了一些错误，请稍后再试。", "Something went wrong on the server. Please try again later."));
</script>
