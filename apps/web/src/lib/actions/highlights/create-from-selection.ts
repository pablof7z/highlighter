import { ndk } from "$stores/ndk";
import { getText, getParagraph, getTextFromSelection, getParagraphFromSelection } from "$utils/text";
import { NDKArticle, NDKEvent, NDKHighlight, NDKKind, NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";

const DEFAULT_ALT = "This is a highlight"

/**
 * Creates a highlight event, signs it, and returns it
 * without publishing
 * @param selection 
 * @param tags 
 * @returns 
 */
export default async function createHighlightFromSelection(
    selection: Selection,
    event: NDKEvent | NDKArticle | NDKVideo,
    tags: NDKTag[] = []
) {
    const $ndk = get(ndk);
    const highlight = new NDKHighlight($ndk);

    const content = getTextFromSelection(selection);
    let context: string | undefined = getParagraphFromSelection(selection);

    // if content is too short, don't create a highlight
    if (content.length < 5) return null;

    // if context is too large, remove it
    if (context.length > content.length * 20) context = undefined;
    
    highlight.kind = NDKKind.Highlight;
    highlight.content = getTextFromSelection(selection);
    highlight.tags = [
        ...event.referenceTags(),
        ...tags
    ]

    if (!highlight.alt) {
        let alt: string = "This is a highlight";
        
        if ((event as NDKArticle).title) {
            alt += " of '" + (event as NDKArticle).title + "'.";
        }

        alt += `\n\nhttps://highlighter.com/a/${event.encode()}`;
        highlight.alt = alt;
    }

    if (context) highlight.tags.push([ "context", context ]);

    if (highlight.content.length < 5) return null;

    await highlight.sign();

    return highlight;
}