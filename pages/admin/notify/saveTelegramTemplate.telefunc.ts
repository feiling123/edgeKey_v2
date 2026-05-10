import { assertAdminAccess } from "../../../modules/auth/service";
import { saveTelegramTemplate } from "../../../modules/notify/service";

export async function onSaveTelegramTemplate(input: {
  scene: "TEST" | "ORDER_PAID" | "DELIVERY_SUCCESS" | "DELIVERY_FAILED";
  name: string;
  content: string;
  isEnabled: boolean;
}) {
  assertAdminAccess();
  return saveTelegramTemplate(input);
}
