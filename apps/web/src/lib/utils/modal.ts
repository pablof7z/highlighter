import { modal } from "$stores/layout";

export function openModal(component: ConstructorOfATypedSvelteComponent, props?: { [key: string]: any }) {
    modal.set({ component, props: props ?? {} });
}

export function closeModal() {
    modal.set(null);
}