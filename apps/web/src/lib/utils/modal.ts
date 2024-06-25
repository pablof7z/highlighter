import { appMobileView } from "$stores/app";
import { openModal as openModalReal, closeModal as closeModalReal } from "svelte-modals";
import { modals } from "$stores/layout";
import { get } from "svelte/store";
import { SvelteComponent } from "svelte";

export function openModal(component: typeof SvelteComponent, props?: { [key: string]: any }) {
    const $appMobileView = get(appMobileView);

    if (!$appMobileView) {
        openModalReal(component, props);
    }
    
    modals.update($modals => {
        $modals.push({ component, props: props ?? {} })
        return $modals;
    });//.set({ component, props: props ?? {} });
}

export function closeModal(component?: typeof SvelteComponent) {
    const $appMobileView = get(appMobileView);
    
    if (!$appMobileView) {
        closeModalReal();
    }
    
    modals.update($modals => {
        if (component) {
            $modals = $modals.filter(m => m.component !== component);
        } else {
            $modals.pop();
        }
        return $modals;
    })
}

export function replaceModal(component: typeof SvelteComponent, props?: { [key: string]: any }) {
    const $appMobileView = get(appMobileView);
    
    if (!$appMobileView) {
        closeModalReal();
        setTimeout(() => openModalReal(component, props), 100);
    }
    
    // modal.set({ component, props: props ?? {} });
}