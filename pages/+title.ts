export default function title(pageContext: any) {
  return pageContext.title || pageContext.site?.siteName;
}
