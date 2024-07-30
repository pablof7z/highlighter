import { nicelyFormattedMilliSatNumber } from '$utils';
import type { NDKSubscriptionAmount, NDKTag } from '@nostr-dev-kit/ndk';

export const possibleCurrencies = ['USD', 'EUR', 'msat'];

export function currencyCode(currency: string) {
	switch (currency) {
		case 'USD':
			return 'USD';
		case 'EUR':
			return 'Euros';
		case 'msat':
			return 'Bitcoin';
		default:
			return currency;
	}
}

export function currencySymbol(currency: string) {
	switch (currency) {
		case 'USD':
			return '$';
		case 'EUR':
			return '€';
		case 'msat':
			return 'sats';
		default:
			return currency;
	}
}

export function currencyFormat(currency: string, amount: number) {
	let retval: string;

	switch (currency) {
		case 'USD':
		case 'usd':
			if (amount > 0) amount /= 100;
			retval = `$${amount.toFixed(2)}`;
			break;
		case 'EUR':
			if (amount > 0) amount /= 100;
			retval = `${amount.toFixed(2)}€`;
			break;
		case 'msat':
			let formatted = nicelyFormattedMilliSatNumber(amount);
			if (typeof formatted === "number") formatted = formatted.toString();
			return formatted.toLowerCase().endsWith('btc') ? formatted : `${formatted} sats`
		default:
			return `${amount} ${currency}`;
	}

	if (retval.endsWith('.00')) {
		retval = retval.slice(0, -3);
	}

	return retval;
}

export async function getBitcoinPrice(currency: string) {
	const response = await fetch(
		'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=' +
			currency.toLowerCase()
	);
	const data = await response.json();
	return data.bitcoin[currency.toLowerCase()]
}

/**
 * Calculate the amount of sats from an amount tag
 * @param amountTag
 * @returns
 */
export async function calculateSatAmountFromAmountTag(amountTag: NDKTag): Promise<number> {
	const value = parseFloat(amountTag[1]);
	const currency = amountTag[2];

	if (['USD', 'EUR'].includes(currency)) {
		const bitcoinPrice = await getBitcoinPrice(currency);
		return Math.floor((Number(value) / bitcoinPrice) * 100_000_000) / 100; // expressed in cents in the tag
	} else if (currency === 'msat') {
		return value / 1000; // expressed in msats in the tag
	} else {
		throw new Error('Currency not supported');
	}
}

export async function calculateSatAmountFromAmount(data: NDKSubscriptionAmount): Promise<number> {
	const { amount, currency } = data;

	if (['USD', 'EUR'].includes(currency)) {
		const bitcoinPrice = await getBitcoinPrice(currency);
		return Math.floor((Number(amount) / bitcoinPrice) * 100_000_000) / 100; // expressed in cents in the tag
	} else if (currency === 'msat') {
		return amount / 1000; // expressed in msats in the tag
	} else {
		throw new Error('Currency not supported');
	}
}