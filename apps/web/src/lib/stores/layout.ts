import { writable, type Writable } from 'svelte/store';
import { NavigationOption } from '../../app';
import { appMobileHideNewPostButton } from './app';

/**
 * `list-column` - The sidebar takes about 1/3 of the screen and the main content takes about 2/3 of the screen
 */
type LayoutMode = "content-focused" | "full-width" | "single-column-focused";

export const layoutMode = writable<LayoutMode>("single-column-focused");

export const pageHeaderComponent = writable<Component | null>(null);

/**
 * These are the options that are rendered within the main container as the options
 * to navigate within this page
 */
export const pageNavigationOptions = writable<NavigationOption[]>([]);
export const pageNavigationOptionsValue = writable<string | undefined>();

interface Component {
	component: ConstructorOfATypedSvelteComponent;
	props: { [key: string]: any };
	containerClass?: string;
}

export const detailView: Writable<Component | null> = writable(null);

export const pageHeader = writable<PageHeader | null>(null);

export const modal = writable<Component | null>(null);

export function resetLayout() {
	layoutMode.set("single-column-focused");
	pageHeaderComponent.set(null);
	pageNavigationOptions.set([]);
	pageHeader.set(null);
	appMobileHideNewPostButton.set(false);
	detailView.set(null);
	pageNavigationOptionsValue.set(undefined);
}

resetLayout();

export const searching: Writable<boolean> = writable(false);

export const modalState: Writable<"open" | "closing" | "closed"> = writable("closed");

export const activeNewPostId: Writable<string | null> = writable(null);

export type PageHeader = {
	/**
	 * Component to be displayed on the main content area. If this is set, all other options will be ignored
	 */
	component?: ConstructorOfATypedSvelteComponent;
	props?: { [key: string]: any };
	on?: { [key: string]: (e: any) => void };

	/**
	 * Title to be displayed
	 */
	title?: string;
	subtitle?: string;

	/**
	 * Always show search bar on the main content area
	 */
	searchBar?: boolean;
	searchFn?: (searchTerm: string) => void;

	/**
	 * Left button options
	 */
	left?: {
		component?: Component;
		icon?: any;
		label?: string;
		url?: string;
		fn?: () => void;
	};

	/**
	 * Right button options
	 */
	right?: {
		component?: any;
		icon?: any;
		label?: string;
		url?: string;
		fn?: () => void;
	};

	subNavbarOptions?: NavigationOption[];
	subNavbarValue?: string;

	footer?: Component;
};
