import { assertAdminAccess } from "../../../modules/auth/service";
import { saveBlogCategory } from "../../../modules/blog/service";

export async function onSaveBlogCategory(input: Parameters<typeof saveBlogCategory>[0]) {
  assertAdminAccess();
  return saveBlogCategory(input);
}
