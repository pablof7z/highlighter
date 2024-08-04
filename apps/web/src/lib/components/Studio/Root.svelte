<script lang="ts">
	import currentUser from "$stores/currentUser";
    import * as User from "$components/User";
	import { setContext } from "svelte";
	import { writable } from "svelte/store";
	import { Thread } from "$utils/thread";
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import { type Mode, Types, PublishInGroupStore, Scope, PublishInTierStore } from ".";
    import { getDraft } from "./draft.js";
	import { DraftItem } from "$stores/drafts";
	import { ndk } from "$stores/ndk";
	import { eventToKind } from "$utils/event";
	import LoadingScreen from "$components/LoadingScreen.svelte";

    export let draftId: string | undefined = undefined;
    export let checkpointId: string | undefined = undefined;
    export let eventId: string | undefined = undefined;

    let draft: DraftItem | undefined;

    const relays = writable(new Set());
    const thread = writable<Thread | undefined>();
    const event = writable<NDKArticle | NDKVideo>();
    const preview = writable<NDKArticle | NDKVideo | undefined>();
    const withPreview = writable<boolean>(true);
    
    const mode = writable<Mode>('edit');
    const type = writable<Types>();

    const publishAt = writable<Date | undefined>();
    const publishScope = writable<Scope>('public');
    const makePublicIn = writable<Date | undefined>();
    export let publishInGroups: PublishInGroupStore;
    const publishInTiers: PublishInTierStore = writable(new Map());
    let ready = true;

    if (draftId) {
        const res = getDraft(draftId, checkpointId);
        console.log({getDraft: res})
        if (res) {
            draft = res.draft;
            if (res.article) $event = res.article as NDKArticle;
        }
    }

    let error: string | undefined = undefined;

    if (eventId) {
        ready = false;
        $ndk.fetchEvent(eventId).then((e) => {
            if (e) {
                $event = eventToKind(e) as NDKArticle | NDKVideo;
                ready = true;
            }
        });
    }

    setContext('mode', mode);
    setContext('publishScope', publishScope);
    setContext('relays', relays);
    setContext('event', event);
    setContext('preview', preview);
    setContext('thread', thread);
    setContext('type', type);
    setContext('publishInGroups', publishInGroups);
    setContext('makePublicIn', makePublicIn);
</script>

{#if $currentUser}
    <LoadingScreen {ready}>
        <User.Root
            user={$currentUser}
            let:authorUrl
            let:groupsList
        >
            <slot
                {mode}
                {publishScope}
                {groupsList}
                {thread}
                {event}
                {preview}
                {draft}
                {authorUrl}
                {draftId}
                {type}
                {withPreview}
                {publishAt}
                {publishInGroups}
                {publishInTiers}
                {makePublicIn}
            />
        </User.Root>
    </LoadingScreen>
{/if}