import Root from './Root.svelte';
import Editor from './Editor.svelte';
import Attachments from './Attachments.svelte';
import { NDKEvent, NDKKind, NDKRelaySet, NDKTag } from '@nostr-dev-kit/ndk';
import { EventDispatcher } from 'svelte';

export type Actions = {
    publish: () => void;
    upload: () => void;
    schedule: () => void;
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

    relaySet?: NDKRelaySet;

    dispatch: EventDispatcher<any>;
};

export {
    Root,
    Editor,
    Attachments
}