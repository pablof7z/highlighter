import { NDKSubscriptionAmount } from "@nostr-dev-kit/ndk";
import Root from "./Root.svelte";
import Profile from "./Profile.svelte";
import Monetization from "./Monetization.svelte";
import Pricing from "./Pricing.svelte";

export type CreateState = {
    name?: string;
    about?: string;
    picture?: string;
    relays?: string[];

    amounts?: NDKSubscriptionAmount[];

    monetization?: 'v4v' | 'subscription';

    gate?: 'open' | 'closed';
};

export {
    Root,
    Profile,
    Monetization,
    Pricing
}