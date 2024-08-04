import { writable, type Writable } from 'svelte/store';
import { NavigationOption } from '../../app';
import { appMobileHideNewPostButton } from './app';
import { NDKEvent } from '@nostr-dev-kit/ndk';

/**
 * `list-column` - The sidebar takes about 1/3 of the screen and the main content takes about 2/3 of the screen
 */
type LayoutMode = "content-focused" | "full-width" | "single-column-focused" | "mobile-full-screen";

export const layoutMode = writable<LayoutMode>("single-column-focused");

export interface Component {
	component: ConstructorOfATypedSvelteComponent;
	props?: { [key: string]: any };
	containerClass?: string;
}

export const pageHeader = writable<PageHeader | null>(null);

export const modals = writable<Component[]>([]);

export function resetLayout() {
	layoutMode.set("single-column-focused");
	pageHeader.set(null);
	appMobileHideNewPostButton.set(false);
}

export const searching: Writable<boolean> = writable(false);

export const modalState: Writable<"open" | "closing" | "closed"> = writable("closed");

export const activeNewPostId: Writable<string | null> = writable(null);

export const footerMainView = writable<string | undefined>(undefined);

export type Layout = {
	/**
	 * Can be used to display information and actions
	 * for a particular event.
	 */
	event?: NDKEvent;
	
	header?: Component | false;
	headerOptions?: NavigationOption[];
	navigation?: NavigationOption[] | false;
	activeOption: NavigationOption | null;
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
		options?: NavigationOption[];
		url?: string;
		fn?: () => void;
	};

	subNavbarOptions?: NavigationOption[];
	subNavbarValue?: string;

	footer?: Component;
};
