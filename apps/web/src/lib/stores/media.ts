import { writable } from "svelte/store";

type MediaItem = {
    mediaUrl: string;
    url?: string;
    title?: string;
    eventId?: string;
}

export const loadedMedia = writable<MediaItem[]>([]);

export const loadedMediaStatus = writable<"playing" | "paused" | undefined>(undefined); 

export function play(item: MediaItem) {
    loadedMedia.set([item]);
}

export function togglePause() {
    loadedMediaStatus.update(status => {
        return status === "paused" ? "playing" : "paused";
    });
}