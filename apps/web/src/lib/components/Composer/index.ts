import Root from './Root.svelte';
import Editor from './Editor.svelte';
import Attachments from './Attachments.svelte';
import { NDKEvent, NDKKind, NDKTag } from '@nostr-dev-kit/ndk';
import { EventDispatcher } from 'svelte';
import { State as AudienceState } from "$components/Audience";
export * from './serializer.js'

export type Actions = {
    publish: () => void;
    upload: () => void;
    schedule: () => void;
    saveDraft: (manuallySaved: boolean) => void;
};

export type State = {
    // Content of the event
    content?: string;

    // Attachments to the event
    attachments?: string[];

    // When set, the Attachments component will show a file upload dialog
    forceFileUpload?: boolean;

    kind?: NDKKind;
    tags?: NDKTag[];
    replyTo?: NDKEvent;
    mentionEvent?: NDKEvent;

    dispatch: EventDispatcher<any>;

    audience: AudienceState;

    draftId?: string;
};

export {
    Root,
    Editor,
    Attachments
}