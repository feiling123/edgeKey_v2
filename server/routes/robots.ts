import type { Hono } from "hono";
import { adminPublicPath } from "../../lib/admin-path";

export function registerRobotsRoutes(app: Hono) {
  app.get("/robots.txt", (c) => {
    const origin = new URL(c.req.url).origin;
    const adminBase = adminPublicPath(c.env as { ADMIN_PATH?: string } | undefined);

    let robotsTxt = `User-agent: *
Disallow: /api/
Sitemap: ${origin}/sitemap.xml
`;

    return c.text(robotsTxt, 200, {
      "Content-Type": "text/plain",
      "Cache-Control": "public, max-age=86400",
    });
  });
}
