<template>
  <dialog ref="dialogRef" class="modal">
    <div class="modal-box">
      <h3 class="text-lg font-bold">{{ state.title }}</h3>
      <p class="py-4 text-base-content/80">{{ state.message }}</p>
      <div class="modal-action">
        <AppButton :variant="state.danger ? 'danger' : 'primary'" @click="resolve(true)">{{ state.confirmText ?? l("确认", "Confirm") }}</AppButton>
        <AppButton v-if="!state.alertMode" variant="ghost" @click="resolve(false)">{{ state.cancelText ?? l("取消", "Cancel") }}</AppButton>
      </div>
    </div>
    <form method="dialog" class="modal-backdrop"><button @click="resolve(false)">close</button></form>
  </dialog>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue";
import AppButton from "./AppButton.vue";
import { useI18n } from "../lib/client-i18n";

const dialogRef = ref<HTMLDialogElement>();
const { l } = useI18n();

const state = reactive({
  title: "",
  message: "",
  confirmText: "",
  cancelText: "",
  danger: false,
  alertMode: false,
});

let _resolve: ((v: boolean) => void) | null = null;

function resolve(value: boolean) {
  dialogRef.value?.close();
  _resolve?.(value);_resolve = null;
}

function confirm(options: { title: string; message: string; confirmText?: string; cancelText?: string; danger?: boolean }): Promise<boolean> {
  state.title = options.title;
  state.message = options.message;
  state.confirmText = options.confirmText ?? l("确认", "Confirm");
  state.cancelText = options.cancelText ?? l("取消", "Cancel");
  state.danger = options.danger ?? false;
  state.alertMode = false;
  dialogRef.value?.showModal();
  return new Promise((res) => { _resolve = res; });
}

function alert(options: { title: string; message: string; confirmText?: string }): Promise<void> {
  state.title = options.title;
  state.message = options.message;
  state.confirmText = options.confirmText ?? l("知道了", "OK");
  state.alertMode = true;
  state.danger = false;
  dialogRef.value?.showModal();
  return new Promise((res) => { _resolve = () => res(); });
}

defineExpose({ confirm, alert });
</script>
