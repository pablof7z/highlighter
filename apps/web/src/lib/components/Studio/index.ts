import Root from "./Root.svelte";
import Shell from "./Shell.svelte";
import { State as Audience } from "$components/Audience";
import { Article } from "$components/Card";
import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
import { Thread } from "$utils/thread";
import * as Editor from "./Editor/";
import * as Preview from "./Preview/";

export type Type = "article" | "video" | "thread";

export type Mode = "view" | "edit" | "audience" | "preview" | "publish";

type ArticleState = {
    article: NDKArticle;
    preview?: NDKArticle;
}

type VideoState = {
    video: NDKVideo;
    preview?: NDKVideo;
}

type ThreadState = {
    thread: Thread;
}

export type StateProperties<T extends Type> =
    T extends "article" ? ArticleState :
    T extends "video" ? VideoState :
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
} & StateProperties<T>;

export type Actions = {
    saveDraft: (manuallySaved: boolean) => Promise<boolean>;
    publish: () => void;
}

export {
    Root,
    Shell,

    Editor,
    Preview
}