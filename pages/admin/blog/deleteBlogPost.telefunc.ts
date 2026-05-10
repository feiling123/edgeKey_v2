import { assertAdminAccess } from "../../../modules/auth/service";
import { deleteBlogPost } from "../../../modules/blog/service";

export async function onDeleteBlogPost(input: { id: number }) {
  assertAdminAccess();
  return deleteBlogPost(input);
}
