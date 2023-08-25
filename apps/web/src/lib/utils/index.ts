import type { NDKEvent } from "@nostr-dev-kit/ndk";

const kinds: Record<number, string> = {
    5000: "Text extraction",
    5001: "Summarization",
    5002: "Translation",

    5100: "Image Generation",

    5200: "Video Translation",

    5300: "Discover Content Algorithms",
    5301: "Discover People Algorithms",
    5302: "Nostr Filtering",

    5900: 'Nostr Timestamping'
};

export function kindToText(kind: number): string {
    if (kind in kinds) {
        return kinds[kind];
    }

    return `Unknown kind ${kind}`;
}

export function kindToDescription(kind: number): string | undefined {
    switch (kind) {
        case 5000: return "Extracts text from an image, audio, video or anything else";
        case 5001: return "Summarizes a text";
        case 5002: return "Translates a text";

        case 5100: return "Generates an image";

        case 5300: return "Discover new content";
        case 5301: return "Discover people in nostr";
        case 5302: return "Filter in or out people or content in nostr";

        case 5900: return "Opentimestamp nostr events";
    }
}

export const jobRequestKinds = Object.keys(kinds).map((k) => parseInt(k));

export function eventUserReference(event: NDKEvent): string {
    return "#" + event.id.slice(0, 4);
}