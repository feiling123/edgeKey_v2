export default function description(pageContext: any) {
  return pageContext.description || pageContext.site?.siteSubtitle || "Digital delivery store";
}
