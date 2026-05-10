import { assertAdminAccess } from "../../../modules/auth/service";
import { activateTelegramConfig, clearTelegramLogs, deleteTelegramConfig, saveTelegramConfig, saveTelegramPushSettings } from "../../../modules/notify/service";

type SaveTelegramConfigInput = {
  id?: number;
  name?: string;
  botToken: string;
  chatId: string;
  apiBaseUrl?: string;
  parseMode?: "NONE" | "HTML" | "MARKDOWN_V2";
  isEnabled?: boolean;
  notifyOrderPaid?: boolean;
  notifyDeliverySuccess?: boolean;
  notifyDeliveryFailed?: boolean;
};

export async function onSaveTelegramConfig(input: SaveTelegramConfigInput) {
  assertAdminAccess();
  return saveTelegramConfig(input as any);
}

export async function onDeleteTelegramConfig(id: number) {
  assertAdminAccess();
  return deleteTelegramConfig(id);
}

export async function onSaveTelegramPushSettings(input: {
  notifyOrderPaid: boolean;
  notifyDeliverySuccess: boolean;
  notifyDeliveryFailed: boolean;
}) {
  assertAdminAccess();
  return saveTelegramPushSettings(input);
}

export async function onActivateTelegramConfig(id: number) {
  assertAdminAccess();
  return activateTelegramConfig(id);
}

export async function onClearTelegramLogs() {
  assertAdminAccess();
  return clearTelegramLogs();
}
