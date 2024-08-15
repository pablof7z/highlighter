import { writable, type Writable } from 'svelte/store';
import { NavigationOption } from '../../app';
import { NDKEvent } from '@nostr-dev-kit/ndk';
import { E } from 'vitest/dist/reporters-O4LBziQ_.js';

export interface Component {
	component: ConstructorOfATypedSvelteComponent;
	props?: { [key: string]: any };
	containerClass?: string;
}

export const modals = writable<Component[]>([]);

export const searching: Writable<boolean> = writable(false);

export const modalState: Writable<"open" | "closing" | "closed"> = writable("closed");

export const footerMainView = writable<string | undefined | false>(undefined);

export type Layout = {
	/**
	 * Can be used to display information and actions
	 * for a particular event.
	 */
	event?: NDKEvent;

	headerCanBeTransparent?: boolean;
	
	header?: Component | false;
	headerOptions?: NavigationOption[];
	navigation?: NavigationOption[] | false;
	activeOption?: NavigationOption | null;
	forceShowNavigation?: boolean;
	sidebar?: Component | false;
	footer?: Component;

	footerInMain?: boolean;

	title?: string;
	iconUrl?: string;

	fullWidth?: boolean;

	back?: {
		url?: string;
		fn?: () => void;
		icon?: any;
		label?: string;
	}

	options?: NavigationOption[];
};

export const layout = writable<Layout>({});

export const scrollPercentage = writable<number>(0);

export const headerTouchFns = writable({} as {
	start?: (e: TouchEvent) => void,
	move?: (e: TouchEvent) => void,
	end?: (e: TouchEvent) => void,
})