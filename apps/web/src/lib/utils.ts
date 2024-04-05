import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
	return twMerge(clsx(inputs));
}

export function pluralize(n: number, singular: string, plural: string = `${singular}s`) {
	return n === 1 ? singular : plural;
}