import { writable } from "svelte/store";

/**
 * Whether we are displaying as a mobile view.
 * This is set by the top-level layout.
 */
export const appMobileView = writable(false);

/**
 * Whether to hide the floating new post button.
 */
export const appMobileHideNewPostButton = writable(false);