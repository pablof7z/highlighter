import { appMobileView } from "$stores/app";
import { openModal as openModalReal, closeModal as closeModalReal } from "svelte-modals";
import { modal } from "$stores/layout";
import { get } from "svelte/store";
import { SvelteComponent } from "svelte";

export function openModal(component: typeof SvelteComponent, props?: { [key: string]: any }) {
    const $appMobileView = get(appMobileView);

    console.log($appMobileView);

    if (!$appMobileView) {
        openModalReal(component, props);
    }
    
    modal.set({ component, props: props ?? {} });
}

export function closeModal() {
    const $appMobileView = get(appMobileView);
    
    if (!$appMobileView) {
        closeModalReal();
    }
    
    modal.set(null);
}

export function replaceModal(component: typeof SvelteComponent, props?: { [key: string]: any }) {
    const $appMobileView = get(appMobileView);
    
    if (!$appMobileView) {
        closeModalReal();
        setTimeout(() => openModalReal(component, props), 100);
    }
    
    modal.set({ component, props: props ?? {} });
}