import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import { cubicOut } from "svelte/easing";
import type { TransitionConfig } from "svelte/transition";

export function pluralize(n: number, singular: string, plural: string = `${singular}s`) {
	return n === 1 ? singular : plural;
}

export function cn(...inputs: ClassValue[]) {
	return twMerge(clsx(inputs));
}

type FlyAndScaleParams = {
	y?: number;
	x?: number;
	start?: number;
	duration?: number;
};

export const flyAndScale = (
	node: Element,
	params: FlyAndScaleParams = { y: -8, x: 0, start: 0.95, duration: 150 }
): TransitionConfig => {
	const style = getComputedStyle(node);
	const transform = style.transform === "none" ? "" : style.transform;

	const scaleConversion = (
		valueA: number,
		scaleA: [number, number],
		scaleB: [number, number]
	) => {
		const [minA, maxA] = scaleA;
		const [minB, maxB] = scaleB;

		const percentage = (valueA - minA) / (maxA - minA);
		const valueB = percentage * (maxB - minB) + minB;

		return valueB;
	};

	const styleToString = (
		style: Record<string, number | string | undefined>
	): string => {
		return Object.keys(style).reduce((str, key) => {
			if (style[key] === undefined) return str;
			return str + `${key}:${style[key]};`;
		}, "");
	};

	return {
		duration: params.duration ?? 200,
		delay: 0,
		css: (t) => {
			const y = scaleConversion(t, [0, 1], [params.y ?? 5, 0]);
			const x = scaleConversion(t, [0, 1], [params.x ?? 0, 0]);
			const scale = scaleConversion(t, [0, 1], [params.start ?? 0.95, 1]);

			return styleToString({
				transform: `${transform} translate3d(${x}px, ${y}px, 0) scale(${scale})`,
				opacity: t
			});
		},
		easing: cubicOut
	};
};

export function nicelyFormattedMilliSatNumber(amount: number) {
    return nicelyFormattedSatNumber(
        Math.floor(amount / 1000)
    );
}

export function nicelyFormattedSatNumber(amount: number) {
	let format = (num: string): string => {
		const str = num;
		const parts = str.split(".");
		console.log({num, parts})
		
		if (parts.length === 1) return str;

		// remove trailing zeros
		const decimals = parts[1].replace(/0+$/, "");
		if (decimals === "") return parts[0];
		return `${parts[0]}.${decimals}`;
	}

    // if the number is less than 1000, just return it
    if (amount < 1000) return amount.toString();

    if (amount < 10000) return `${format((amount / 1000).toFixed(2))}k`;

    // if the number is less than 1 million, return it with a k, if the comma is not needed remove it
    if (amount < 1000000) return `${format((amount / 1000).toFixed(0))}k`;

    // if the number is less than 1 billion, return it with an m
    if (amount < 1000000000) return `${format((amount / 1000000).toFixed(1))}m`;

    return `${format((amount / 100_000_000).toFixed(2))} btc`;
}