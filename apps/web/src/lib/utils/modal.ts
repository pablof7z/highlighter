import { appMobileView } from "$stores/app";
import { modals } from "$stores/layout";
import { SvelteComponent } from "svelte";

export function openModal(component: typeof SvelteComponent, props?: { [key: string]: any }) {
    modals.update($modals => {
        $modals.push({ component, props: props ?? {} })
        return $modals;
    });
}

export function closeModal(component?: typeof SvelteComponent) {
    modals.update($modals => {
        if (component) {
            $modals = $modals.filter(m => m.component !== component);
        } else {
            $modals.pop();
        }
        return $modals;
    })
}
