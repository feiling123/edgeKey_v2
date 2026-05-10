import { getAdminBlogData } from "../../../modules/blog/service";

export type Data = Awaited<ReturnType<typeof data>>;

export async function data(pageContext: {
  prisma: import("../../../generated/prisma/client").PrismaClient;
  session?: { user?: { role?: string } };
}) {
  if (pageContext.session?.user?.role !== "admin") {
    return {
      categories: [],
      posts: [],
    };
  }

  return getAdminBlogData(pageContext.prisma);
}
