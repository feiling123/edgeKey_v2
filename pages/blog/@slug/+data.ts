import { getPublicBlogDetail } from "../../../modules/blog/service";

export type Data = Awaited<ReturnType<typeof data>>;

export async function data(pageContext: {
  prisma: import("../../../generated/prisma/client").PrismaClient;
  routeParams: { slug: string };
}) {
  return getPublicBlogDetail(pageContext.routeParams.slug, pageContext.prisma);
}
