import { writable, type Writable } from 'svelte/store';
import { NavigationOption } from '../../app';
import { NDKEvent } from '@nostr-dev-kit/ndk';

/**
 * `list-column` - The sidebar takes about 1/3 of the screen and the main content takes about 2/3 of the screen
 */
type LayoutMode = "content-focused" | "full-width" | "single-column-focused" | "mobile-full-screen";

export interface Component {
	component: ConstructorOfATypedSvelteComponent;
	props?: { [key: string]: any };
	containerClass?: string;
}

export const modals = writable<Component[]>([]);

export const searching: Writable<boolean> = writable(false);

export const modalState: Writable<"open" | "closing" | "closed"> = writable("closed");

export const footerMainView = writable<string | undefined>(undefined);

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
