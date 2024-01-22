import { writable, type Writable } from 'svelte/store';

interface Component {
    component: ConstructorOfATypedSvelteComponent;
    props: { [key: string]: any };
}

export const pageSidebar: Writable<Component | null> = writable(null);
export const hideMobileBottomBar: Writable<boolean> = writable(false);
export const sidebarPlacement: Writable<"left" | "right"> = writable("left");

export type PageHeader = {
    /**
     * Title to be displayed
     */
    title?: string;

    /**
     * Left button options
     */
    leftLabel?: string;
    leftUrl?: string;
    leftFn?: () => void;

    /**
     * Right button options
     */
    rightLabel?: string;
    rightUrl?: string;
    rightFn?: () => void;
};

export const pageHeader = writable<PageHeader | null>(null);
