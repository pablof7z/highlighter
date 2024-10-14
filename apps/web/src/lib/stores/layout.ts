import { get, writable, type Writable } from 'svelte/store';
import { NavigationOption } from '../../app';
import { NDKEvent } from '@nostr-dev-kit/ndk';
import { onDestroy, onMount } from 'svelte';

export function setLayout(layoutOpts: Layout) {
	const currentLayout = get(layout);

	onMount(() => {
		layout.set(layoutOpts);
	});

	onDestroy(() => {
		layout.set(currentLayout);
	});
}

export interface Component {
	component: ConstructorOfATypedSvelteComponent;
	props?: { [key: string]: any };
	containerClass?: string;
}

export const modals = writable<Component[]>([]);

export const searching: Writable<boolean> = writable(false);

export const modalState: Writable<"open" | "closing" | "closed"> = writable("closed");

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

	navSidebar?: boolean;

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

export function l(layoutOpts: Layout) {
	layout.set(layoutOpts);
}

export const layout = writable<Layout>({});

export const scrollPercentage = writable<number>(0);
