import { nicelyFormattedMilliSatNumber } from "@kind0/ui-common";

export function currencySymbol(currency: string) {
    switch (currency) {
        case "USD":
            return "$";
        case "EUR":
            return "€";
        case "msat":
            return "sats";
        default:
            return currency;
    }
}

export function currencyFormat(currency: string, amount: number) {
    switch (currency) {
        case "USD":
            return `$${amount.toFixed(2)}`;
        case "EUR":
            return `${amount.toFixed(2)}€`;
        case "msat":
            return nicelyFormattedMilliSatNumber(amount) + ' sats';
        default:
            return `${amount} ${currency}`;
    }
}