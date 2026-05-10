import { computed } from "vue";
import { usePageContext } from "vike-vue/usePageContext";

export function useAdminPath() {
  const pageContext = usePageContext();
  const adminBase = computed(() => pageContext.adminBase || "/admin");

  function adminHref(path = "/admin") {
    const base = adminBase.value || "/admin";
    if (!path || path === "/admin") return base;
    if (path.startsWith("/admin/")) return `${base}${path.slice("/admin".length)}`;
    return path;
  }

  return { adminBase, adminHref };
}
