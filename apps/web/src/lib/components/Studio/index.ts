import Root from "./Root.svelte";
import Shell from "./Shell.svelte";
import PrepublishModal from "./PrepublishModal.svelte";
import { State as Audience } from "$components/Audience";
import { NDKArticle, NDKEvent, NDKVideo } from "@nostr-dev-kit/ndk";
import { Thread } from "$utils/thread";
import * as Editor from "./Editor/";
import * as Preview from "./Preview/";
import * as Drafts from "./Drafts/";

export * from './serializer.js';

export enum Type {
    Article = "article",
    Video = "video",
    Thread = "thread"
}

export type Mode = "view" | "edit" | "audience" | "manage-preview" | "preview" | "publish";

export type PreviewableTypes = Type.Article | Type.Video;

type PreviewableState<T> = {
    withPreview: boolean;
    preview?: T;
    previewAppend?: string;

    /**
     * If the preview should be published broadly, or constrained
     * within the NIP-29 relay
     */
    broadPreviewPublish?: boolean;
}

type ArticleState = PreviewableState<NDKArticle> & {
    article: NDKArticle;
}

type VideoState = PreviewableState<NDKVideo> & {
    video: NDKVideo;
}

type ThreadState = {
    thread: Thread;
}

export type StateProperties<T extends Type> =
    T extends "article" ? ArticleState & PreviewableState<T> :
    T extends "video" ? VideoState & PreviewableState<T> :
    T extends "thread" ? ThreadState :
    never;

export type State<T extends Type> = {
    mode: Mode;
    audience: Audience;

    type: Type;

    // at what time should this be published
    publishAt?: Date;

    // in how many days should this be made public
    publicIn?: number;

    // draft properties
    draftId?: string;

    // validation errors

} & StateProperties<T>;

export type Actions = {
    saveDraft: (manuallySaved: boolean) => Promise<boolean>;
    shouldDraft: () => Promise<boolean>;
    publish: () => void;
}

export {
    Root,
    Shell,

    PrepublishModal,

    Editor,
    Preview,
    Drafts
}

/**
 * Gets the main event in the correct type
 */
export function getEventFromState(state: State<Type>): NDKEvent | undefined {
    if (state.type === 'article') return (state as State<Type.Article>).article;
    if (state.type === 'video') return (state as State<Type.Video>).video;
}

export function getPreviewFromState(state: State<PreviewableTypes>): NDKEvent | undefined {
    let previewEvent: NDKArticle | NDKVideo | undefined;

    if (
        state.withPreview === false ||
        state.audience.scope === 'public'
    ) return undefined;
    
    if (state.type === 'article') previewEvent = (state as State<Type.Article>).preview;
    if (state.type === 'video') previewEvent = (state as State<Type.Video>).preview;
}

/**
 * Gets the event that should be publicly shared
 */
export function getShareableEvent(state: State<Type>): NDKArticle | NDKVideo | NDKEvent | undefined {
    if (state.audience.scope === 'public') {
        return getEventFromState(state);
    }

    if (state.withPreview === false) return undefined;

    return getPreviewFromState(state);
}

export const defaultPreviewFooter = "This is a preview of my post. Join my community and get access to this and more of my work.";