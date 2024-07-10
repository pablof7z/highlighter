import { get, writable } from "svelte/store";
import { layout } from "./layout.js";
import { page } from "$app/stores";

export type HistoryEntry = {
    category?: string;
    title: string;
    url?: string;
    params?: Record<string, string>;
};

export const history = writable<HistoryEntry[]>([]);

export function addHistory({ title, url, params, category }: HistoryEntry) {
    const $layout = get(layout)
    
    title ??= $layout.title as string;

    if (!url) {
        const $page = get(page);
        url = $page.url.toString();;
    }

    if (!title || !url) return false;
    
    history.update((h) => {
        const newEntry = { title, url, params, category };

        const historyWithoutCurrent = h.filter((entry) => entry.url !== url);
        
        return [newEntry, ...historyWithoutCurrent ];
    });
}
