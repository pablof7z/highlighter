import { writable, type Writable } from 'svelte/store';

interface Component {
    component: ConstructorOfATypedSvelteComponent;
    props: { [key: string]: any };
}

export const pageSidebar: Writable<Component | null> = writable(null);