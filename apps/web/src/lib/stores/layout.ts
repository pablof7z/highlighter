import { writable, type Writable } from 'svelte/store';

interface Component {
	component: ConstructorOfATypedSvelteComponent;
	props: { [key: string]: any };
}

export const pageSidebar: Writable<Component | null> = writable(null);
export const hideMobileBottomBar: Writable<boolean> = writable(false);
export const sidebarPlacement: Writable<'left' | 'right'> = writable('left');
export const searching: Writable<boolean> = writable(false);

export type PageHeader = {
	/**
	 * Title to be displayed
	 */
	title?: string;

	/**
	 * Always show search bar on the main content area
	 */
	searchBar?: boolean;
	searchFn?: (searchTerm: string) => void;

	/**
	 * Left button options
	 */
	leftIcon?: any;
	leftLabel?: string;
	leftUrl?: string;
	leftFn?: () => void;

	/**
	 * Right button options
	 */
	rightIcon?: any;
	rightLabel?: string;
	rightUrl?: string;
	rightFn?: () => void;
};

export const pageHeader = writable<PageHeader | null>(null);

export const mainWrapperMargin = writable<string | null>(null);
