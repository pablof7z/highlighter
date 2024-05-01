import { writable, type Writable } from 'svelte/store';
import { NavigationOption } from '../../app';

/**
 * `reversed-columns` - The sidebar takes about 1/3 of the screen and the main content takes about 2/3 of the screen
 */
type LayoutMode = "centered-feed-column" | "content-focused" | "full-width" | "reversed-columns" | "single-column-focused";

export const layoutMode = writable<LayoutMode>("centered-feed-column");

export const layoutNavState = writable<"normal" | "collapsed">("normal");
export const layoutAlign = writable<"left" | "center" | "right">("center");
export const layoutMaxWidth = writable<string | null>(null);
export const contentCentricLayout = writable<boolean>(false);

export const pageHeaderComponent = writable<Component | null>(null);

/**
 * These are the options that are rendered within the main container as the options
 * to navigate within this page
 */
export const pageNavigationOptions = writable<NavigationOption[]>([]);

export const pageMainContentMaxWidth = writable<string | undefined>();
export const mainAlign = writable<"left" | "center" | "right">("left");

interface Component {
	component: ConstructorOfATypedSvelteComponent;
	props: { [key: string]: any };
	containerClass?: string;
}

export const pageSidebar: Writable<Component | null> = writable(null);
export const hideMobileBottomBar: Writable<boolean> = writable(false);

export const detailView: Writable<Component | null> = writable(null);

export function resetLayout() {
	layoutMode.set("centered-feed-column");
	layoutNavState.set("normal");
	layoutAlign.set("center");
	layoutMaxWidth.set(null);
	pageHeaderComponent.set(null);
	pageNavigationOptions.set([]);
	mainAlign.set("left");
	pageMainContentMaxWidth.set(undefined);
	contentCentricLayout.set(false);
	detailView.set(null);
}

resetLayout();

// @deprecated -- Don't use since this is not displayed anywhere
export const sidebarPlacement: Writable<'left' | 'right'> = writable('left');
export const searching: Writable<boolean> = writable(false);

export const modalState: Writable<"open" | "closing" | "closed"> = writable("closed");

export const activeNewPostId: Writable<string | null> = writable(null);

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
		component?: any;
		icon?: any;
		label?: string;
		url?: string;
		fn?: () => void;
	};
};

export const pageHeader = writable<PageHeader | null>(null);

export const mainWrapperMargin = writable<string | null>(null);
export const sectionHeaderMargin = writable<string | null>(null);
