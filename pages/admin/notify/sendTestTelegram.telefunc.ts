import { Abort } from "telefunc";
import { toTelefuncErrorPayload } from "../../../lib/app-error";
import { assertAdminAccess } from "../../../modules/auth/service";
import { sendTestTelegram } from "../../../modules/notify/service";

export async function onSendTestTelegram(input: {
  chatId?: string;
  customContent?: string;
  configId?: number;
}) {
  try {
    assertAdminAccess();
    return await sendTestTelegram(input);
  } catch (error) {
    throw Abort(toTelefuncErrorPayload(error));
  }
}
