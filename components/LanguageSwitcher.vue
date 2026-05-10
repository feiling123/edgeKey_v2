<template>
  <div class="join border border-base-300 bg-base-100 p-0.5" :aria-label="t('language.label')">
    <button
      type="button"
      class="btn btn-xs join-item"
      :class="locale === 'zh' ? 'btn-primary' : 'btn-ghost'"
      @click="setLocale('zh')"
    >
      中
    </button>
    <button
      type="button"
      class="btn btn-xs join-item"
      :class="locale === 'en' ? 'btn-primary' : 'btn-ghost'"
      @click="setLocale('en')"
    >
      EN
    </button>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from "../lib/client-i18n";

const { locale, setLocale, t } = useI18n();
</script>
