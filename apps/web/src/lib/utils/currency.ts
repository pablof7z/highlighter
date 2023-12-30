import { nicelyFormattedMilliSatNumber } from "@kind0/ui-common";

export const possibleCurrencies = [
    "USD",
    "EUR",
    "msat",
];

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
    let retval: string;

    switch (currency) {
        case "USD":
            retval = `$${amount.toFixed(2)}`;
            break;
        case "EUR":
            retval = `${amount.toFixed(2)}€`;
            break;
        case "msat":
            return nicelyFormattedMilliSatNumber(amount) + ' sats';
        default:
            return `${amount} ${currency}`;
    }

    if (retval.endsWith('.00')) {
        retval = retval.slice(0, -3);
    }

    return retval;
}