import Root from './Root.svelte';
import RootList from './RootList.svelte';
import Shell from './Shell.svelte';

import Header from './Header.svelte';

import * as Views from './Views';

import * as Footers from './Footer/';
import * as Sidebars from './Sidebar/index.js';

import Avatar from './Avatar.svelte';
import Name from './Name.svelte';
import PublishedToPills from './PublishedToPills.svelte';

import ListItem from './List/Item.svelte';

import List from './List.svelte';
import { Readable } from 'svelte/store';
import { NDKArticle, NDKEvent, NDKRelaySet, NDKSimpleGroupMemberList, NDKSimpleGroupMetadata, NDKSubscriptionTier, NDKTag, NDKVideo, NDKWiki } from '@nostr-dev-kit/ndk';
import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
export * from './load.js';

export type ContentStores = {
    articles: Readable<NDKArticle[]>;
    videos: Readable<NDKVideo[]>;
    wiki: Readable<NDKWiki[]>;
    notes: Readable<NDKEvent[]>;
    chat: Readable<NDKEvent[]>;
}

export type GroupData = {
    id: string;
    relayUrls: string[];
    relaySet: NDKRelaySet;
    
    name?: string;
    picture?: string;
    about?: string;

    events: NDKEventStore<NDKEvent>;

    metadata?: NDKSimpleGroupMetadata;
    admins?: NDKSimpleGroupMemberList;
    members?: NDKSimpleGroupMemberList;
    tiers?: NDKSubscriptionTier[];

    /**
     * Is the current user an admin of this group?
     */
    isAdmin?: boolean;

    /**
     * Is the current user a member of this group?
     */
    isMember?: boolean;

    access?: 'open' | 'closed';
}

export type GroupContent = {
    events: NDKEventStore<NDKEvent>;
    articles?: Readable<NDKArticle[]>;
    videos?: Readable<NDKVideo[]>;
    wiki?: Readable<NDKWiki[]>;
    notes?: Readable<NDKEvent[]>;
    chat?: Readable<NDKEvent[]>;
}

export {
    Root,
    RootList,
    Shell,

    Avatar,
    Name,
    PublishedToPills,

    Header,

    Views,

    Footers,

    Sidebars,
    
    List,
    ListItem,
}