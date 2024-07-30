import Root from './Root.svelte';
import Shell from './Shell.svelte';

import * as Views from './Views';

import * as Footers from './Footer/';

import List from './List.svelte';
import { Readable } from 'svelte/store';
import { NDKArticle, NDKEvent, NDKVideo, NDKWiki } from '@nostr-dev-kit/ndk';

export type ContentStores = {
    articles: Readable<NDKArticle[]>;
    videos: Readable<NDKVideo[]>;
    wiki: Readable<NDKWiki[]>;
    notes: Readable<NDKEvent[]>;
    chat: Readable<NDKEvent[]>;
}

export {
    Root,
    Shell,

    Views,

    Footers,
    
    List
}