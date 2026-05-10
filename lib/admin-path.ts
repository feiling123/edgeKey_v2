export const INTERNAL_ADMIN_REWRITE_HEADER = "x-edgekey-internal-admin-rewrite";

export function adminPublicPath(env?: { ADMIN_PATH?: string } | NodeJS.ProcessEnv): string {
  const raw = String(env?.ADMIN_PATH || "admin").trim();
  const prefixed = raw.startsWith("/") ? raw : `/${raw}`;
  const normalized = prefixed.replace(/\/+$/g, "");
  if (!normalized || normalized === "/") return "/admin";
  if (!/^\/[A-Za-z0-9/_-]{3,128}$/.test(normalized)) return "/admin";

  const reserved = [
    "/api",
    "/assets",
    "/blog",
    "/order",
    "/product",
    "/query",
    "/_telefunc",
    "/favicon.ico",
    "/robots.txt",
    "/sitemap.xml",
  ];
  if (reserved.some((path) => normalized === path || normalized.startsWith(`${path}/`))) return "/admin";
  return normalized;
}

export function isAdminPath(pathname: string, adminBase: string) {
  return pathname === adminBase || pathname.startsWith(`${adminBase}/`);
}

export function mapPublicAdminPath(url: URL, adminBase: string): URL {
  const suffix = url.pathname === adminBase ? "" : url.pathname.slice(adminBase.length);
  const mapped = new URL(url);
  mapped.pathname = `/admin${suffix || ""}`;
  return mapped;
}

export function nginx404(): Response {
  return new Response(
    `<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>`,
    {
      status: 404,
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Cache-Control": "no-store, max-age=0",
        "X-Content-Type-Options": "nosniff",
      },
    },
  );
}
