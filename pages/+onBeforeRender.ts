import type { PageContextServer } from "vike/types";
import { adminPublicPath } from "../lib/admin-path";
import { getPublicSiteInfo } from "../modules/site/service";

export async function onBeforeRender(pageContext: PageContextServer) {
  const site = await getPublicSiteInfo(pageContext.prisma);
  return {
    pageContext: {
      site,
      adminBase: adminPublicPath(process.env),
      title: site?.siteName || "EdgeKey Store",
      description: site?.siteSubtitle || "Cloudflare Workers digital delivery store",
    },
  };
}
