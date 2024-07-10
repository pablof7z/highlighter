export function roundedItemCount(items: any[], limit = 99): string {
    return items.length > limit ? `${limit}+` : items.length.toString();
}