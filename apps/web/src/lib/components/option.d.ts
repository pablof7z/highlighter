import type { SvelteComponent } from "svelte";

export type Option = {
    value?: string;
    name: string;
    tooltip?: string;
    icon?: any;
    class?: string;
    href?: string;
    id?: string;
    component?: {
        component: typeof SvelteComponent;
        props?: Record<string, any>;
    }
    fn?: () => void;
    premiumOnly?: boolean;
};