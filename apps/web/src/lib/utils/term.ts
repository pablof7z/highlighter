export type Term = "monthly" | "quarterly" | "yearly";

export function termToShort(term: Term): string {
    switch (term) {
        case "monthly": return "mo";
        case "quarterly": return "quarter";
        case "yearly": return "year";
        default: return term;
    }
}