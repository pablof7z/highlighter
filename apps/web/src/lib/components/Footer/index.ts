import { ComponentType } from 'svelte';
import Shell from './Shell.svelte';
import { Writable } from 'svelte/store';

export {
    Shell
}

export type OpenFn = (view?: any | string | false) => void;

/**
 * Views for the footer
 */
export type FooterView = {
    name: string,
    Button?: ComponentType,
    Toolbar?: ComponentType,
    View?: ComponentType,
    buttonProps?: Record<string, any>
    props?: Record<string, any>

    createStateStore?: () => Writable<Record<string, any>>
}