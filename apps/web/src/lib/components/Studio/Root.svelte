<script lang="ts">
	import currentUser from "$stores/currentUser";
    import * as User from "$components/User";
	import { setContext } from "svelte";
	import { writable } from "svelte/store";
	import { Thread } from "$utils/thread";
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import { State, type Type } from ".";
    import { getDraft } from "./draft.js";
	import { DraftItem } from "$stores/drafts";
	import LoadingScreen from "$components/LoadingScreen.svelte";
    import { State as AudienceState } from "$components/Audience";
    import * as Studio from "$components/Studio";
	import { ndk } from "$stores/ndk";

    export let draftId: string | undefined = undefined;
    export let checkpointId: string | undefined = undefined;
    export let eventId: string | undefined = undefined;

    export let audience: AudienceState = { scope: 'public' };

    export let type: Type;
    export let actions: Studio.Actions = {
        saveDraft: () => false,
        publish: () => $state.mode = 'publish',
    }

    function createInitialState<T extends Type>(type: T): State<T> {
        return {
            mode: "edit",
            audience,
            type,
            ...(type === "article" ? { article: new NDKArticle($ndk) } : {}),
            ...(type === "video" ? { video: new NDKVideo($ndk) } : {}),
            ...(type === "thread" ? { thread: {} as Thread } : {}),
        } as State<T>;
    }

    // Initialize the store with the correctly typed state
    const state = writable(createInitialState(type));

    let draft: DraftItem | undefined;


    if (draftId) {
        const res = getDraft(draftId, checkpointId);
        console.log({getDraft: res})
        if (res) {
            draft = res.draft;
            // if (res.article) $event = res.article as NDKArticle;
        }
    }

    let error: string | undefined = undefined;

    let ready = true;

    // if (eventId) {
    //     ready = false;
    //     $ndk.fetchEvent(eventId).then((e) => {
    //         if (e) {
    //             $event = wrapEvent(e) as NDKArticle | NDKVideo;
    //             ready = true;
    //         }
    //     });
    // }

    setContext('state', state);
</script>

{#if $currentUser}
    <LoadingScreen {ready}>
        <User.Root
            user={$currentUser}
            let:authorUrl
        >
            <slot
                {state}
                {actions}
                {authorUrl}
            />
        </User.Root>
    </LoadingScreen>
{/if}