import { assertAdminAccess } from "../../../modules/auth/service";
import { deleteBlogCategory } from "../../../modules/blog/service";

export async function onDeleteBlogCategory(input: { id: number }) {
  assertAdminAccess();
  return deleteBlogCategory(input);
}
