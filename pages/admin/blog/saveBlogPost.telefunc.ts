import { assertAdminAccess } from "../../../modules/auth/service";
import { saveBlogPost } from "../../../modules/blog/service";

export async function onSaveBlogPost(input: Parameters<typeof saveBlogPost>[0]) {
  assertAdminAccess();
  return saveBlogPost(input);
}
