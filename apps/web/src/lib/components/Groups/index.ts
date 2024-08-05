import Root from './Root.svelte';
import RootList from './RootList.svelte';
import Shell from './Shell.svelte';

import Header from './Header.svelte';

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
    RootList,
    Shell,

    Header,

    Views,

    Footers,
    
    List
}