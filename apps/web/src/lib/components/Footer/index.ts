import { ComponentType } from 'svelte';
import Shell from './Shell.svelte';

export {
    Shell
}

export type OpenFn = (view?: any | string | false) => void;

/**
 * Buttons for the footer
 */
export type ButtonView = {
    name: string,
    Button: ComponentType,
    View: ComponentType,
    buttonProps?: Record<string, any>
    props?: Record<string, any>
}