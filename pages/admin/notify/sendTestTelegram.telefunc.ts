import { assertAdminAccess } from "../../../modules/auth/service";
import { sendTestTelegram } from "../../../modules/notify/service";

export async function onSendTestTelegram(input: {
  chatId?: string;
  customContent?: string;
  configId?: number;
}) {
  assertAdminAccess();
  return sendTestTelegram(input);
}
