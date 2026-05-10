import { getPublicBlogIndex } from "../../modules/blog/service";

export type Data = Awaited<ReturnType<typeof data>>;

export async function data(pageContext: {
  prisma: import("../../generated/prisma/client").PrismaClient;
}) {
  return getPublicBlogIndex(pageContext.prisma);
}
