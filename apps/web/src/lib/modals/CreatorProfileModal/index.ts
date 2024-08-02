import { NDKSubscriptionAmount } from '@nostr-dev-kit/ndk';
import Shell from './Shell.svelte';

export type CreateState = {
    name?: string;
    about?: string;
    picture?: string;
    relays?: string[];

    amounts?: NDKSubscriptionAmount[];

    type?: 'personal' | 'theme';

    monetization?: 'v4v' | 'subscription';

    gate?: 'open' | 'closed';
};

export default Shell;