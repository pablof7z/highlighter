import { Readability } from '@mozilla/readability';

export function parse(html: string) {
    const doc = new DOMParser().parseFromString(html, 'text/html');
    const reader = new Readability(doc);
    return reader.parse();
}