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
	 * Component to be displayed on the main content area. If this is set, all other options will be ignored
	 */
	component?: ConstructorOfATypedSvelteComponent | "post-editor";
	props?: { [key: string]: any };
	on?: { [key: string]: (e: any) => void };

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
	left?: {
		icon?: any;
		label?: string;
		url?: string;
		fn?: () => void;
	};

	/**
	 * Right button options
	 */
	right?: {
		icon?: any;
		label?: string;
		url?: string;
		fn?: () => void;
	};
};

export const pageHeader = writable<PageHeader | null>(null);

export const mainWrapperMargin = writable<string | null>(null);
