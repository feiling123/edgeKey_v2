<template>
  <section class="card bg-base-100 shadow-sm">
    <div class="card-body space-y-6">
      <div class="flex items-center justify-between gap-4 max-md:flex-col max-md:items-start">
        <div>
          <h1 class="text-2xl font-bold">{{ l("个人资料", "Profile") }}</h1>
          <p class="text-sm text-base-content/70">{{ l("更新管理员昵称，并可修改登录密码。", "Update the admin nickname and login password.") }}</p>
        </div>
        <span v-if="saved" class="badge badge-success">{{ l("已保存", "Saved") }}</span>
      </div>

      <div v-if="alert" role="alert" class="alert" :class="alert.className">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="h-6 w-6 shrink-0 stroke-current">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="alert.iconPath" />
        </svg>
        <span>{{ alert.message }}</span>
                <AppButton v-if="alert.actionHref" size="sm" :href="alert.actionHref">{{ alert.actionLabel }}</AppButton>
      </div>

      <div v-if="!profile" class="rounded-box bg-base-200 p-4 text-sm text-base-content/70">
        {{ l("未获取到管理员信息，请重新登录后再试。", "Admin profile was not loaded. Please sign in again.") }}
      </div>

      <div v-else class="space-y-6">
        <div class="grid gap-4 md:grid-cols-2">
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ l("用户名", "Username") }}</span>
            <input :value="profile.username" class="input input-bordered w-full" disabled />
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ l("昵称", "Nickname") }}</span>
            <input v-model="form.nickname" class="input input-bordered w-full" :placeholder="l('请输入昵称', 'Enter nickname')" />
          </label>
          <label class="flex flex-col gap-1.5 md:col-span-2">
            <span class="label-text font-medium">{{ l("邮箱", "Email") }}</span>
            <input v-model="form.email" type="email" class="input input-bordered w-full" :placeholder="l('接收系统邮件', 'Receive system emails')" />
          </label>
        </div>

        <div class="divider">{{ l("修改密码", "Change Password") }}</div>

        <div class="grid gap-4 md:grid-cols-3">
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ l("当前密码", "Current Password") }}</span>
            <input v-model="form.currentPassword" type="password" class="input input-bordered w-full" />
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ l("新密码", "New Password") }}</span>
            <input v-model="form.newPassword" type="password" class="input input-bordered w-full" />
          </label>
          <label class="flex flex-col gap-1.5">
            <span class="label-text font-medium">{{ l("确认新密码", "Confirm New Password") }}</span>
            <input v-model="form.confirmPassword" type="password" class="input input-bordered w-full" />
          </label>
        </div>

        <div class="flex items-center gap-3">
          <AppButton variant="primary" :loading="saving" :disabled="!profile" @click="handleSave">{{ l("保存资料", "Save Profile") }}</AppButton>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { normalizeTelefuncError } from "../../../lib/app-error";
import { computed, reactive, ref } from "vue";
import AppButton from "../../../components/AppButton.vue";
import { useData } from "vike-vue/useData";
import { usePageContext } from "vike-vue/usePageContext";
import type { Data } from "./+data";
import { onSaveAdminProfile } from "./saveAdminProfile.telefunc";
import { useI18n } from "../../../lib/client-i18n";

const { profile } = useData<Data>();
const pageContext = usePageContext();
const adminBase = computed(() => pageContext.adminBase || "/admin");
const { l } = useI18n();

const form = reactive({
  nickname: profile?.nickname ?? "",
  email: profile?.email ?? "",
  currentPassword: "",
  newPassword: "",
  confirmPassword: "",
});

const saving = ref(false);
const saved = ref(false);
const alert = ref<null | {
  className: string;
  iconPath: string;
  message: string;
  actionHref?: string;
  actionLabel?: string;
}>(null);

async function handleSave() {
  if (!profile) return;

  saving.value = true;
  saved.value = false;
  alert.value = null;

  try {
    const wantsPasswordChange = Boolean(form.currentPassword || form.newPassword || form.confirmPassword);
    if (wantsPasswordChange && form.newPassword !== form.confirmPassword) {
      alert.value = {
        className: "alert-error",
        iconPath: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z",
        message: l("两次输入的新密码不一致", "The two new passwords do not match"),
      };
      return;
    }

    const result = await onSaveAdminProfile({
      nickname: form.nickname,
      email: form.email,
      currentPassword: wantsPasswordChange ? form.currentPassword : undefined,
      newPassword: wantsPasswordChange ? form.newPassword : undefined,
    });

    form.nickname = result.nickname ?? "";
    form.email = result.email ?? "";
    form.currentPassword = "";
    form.newPassword = "";
    form.confirmPassword = "";
    saved.value = true;

    if (result.passwordUpdated) {
      alert.value = {
        className: "alert-warning",
        iconPath: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
        message: l("密码已更新，请重新登录。", "Password updated. Please sign in again."),
        actionHref: `/api/auth/signout?callbackUrl=${encodeURIComponent(`${adminBase.value}/login`)}`,
        actionLabel: l("重新登录", "Sign in again"),
      };
      return;
    }

    alert.value = {
      className: "alert-success",
      iconPath: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z",
      message: l("资料已保存。", "Profile saved."),
    };
  } catch (error) {
    alert.value = {
      className: "alert-error",
      iconPath: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z",
      message: normalizeTelefuncError(error, l("保存失败", "Save failed")),
    };
  } finally {
    saving.value = false;
  }
}
</script>
