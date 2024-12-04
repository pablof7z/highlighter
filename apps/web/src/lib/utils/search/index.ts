import { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";
import { UserProfileType } from "../../../app";

export type UserSearchResult = { id: string, pubkey: string, profile: NDKUserProfile, avatar?: string, value?: string, nip05?: string, followed: boolean };

export type EventSearchResult = NDKEvent;

export type SearchResultType = "user" | "event";

export type SearchResult = {
    id: string,
    type: SearchResultType,
    result: UserSearchResult | EventSearchResult
};