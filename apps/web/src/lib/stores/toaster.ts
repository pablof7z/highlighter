import { writable } from "svelte/store";

type MessageLevel = 'warn' | 'error' | 'info' | "success";

type ToasterMessage = {
    id: number;
    message: string;
    level: MessageLevel;
}

export const toasterItems = writable<ToasterMessage[]>([]);

export function newToasterMessage(
    message: string,
    level: MessageLevel = 'error',
    duration: number | undefined = 5000
): void {
    const id = Math.floor(Math.random() * 1000000000);
    const item: ToasterMessage = {
        id,
        message,
        level
    };

    toasterItems.update(items => {
        items.unshift(item);
        return items;
    })

    if (duration) {
        setTimeout(() => {
            toasterItems.update(items => {
                items = items.filter(i => i.id !== id);

                return items;
            });
        }, duration);
    }
}