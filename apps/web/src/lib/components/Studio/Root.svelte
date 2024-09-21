<script lang="ts">
	import currentUser from "$stores/currentUser";
    import * as User from "$components/User";
	import { setContext } from "svelte";
	import { writable } from "svelte/store";
	import { Thread } from "$utils/thread";
	import { NDKArticle, NDKVideo } from "@nostr-dev-kit/ndk";
	import { State, type Type } from ".";
    import { createStateFromDraftId } from "./draft.js";
	import LoadingScreen from "$components/LoadingScreen.svelte";
    import { State as AudienceState } from "$components/Audience";
    import * as Studio from "$components/Studio";
	import { ndk } from "$stores/ndk";
    import { saveDraft, shouldSave } from "./actions/draft.js";
	import { wrapEvent } from "$utils/event";

    export let draftId: string | undefined = undefined;
    export let checkpointId: string | undefined = undefined;
    export let eventId: string | undefined = undefined;

    export let audience: AudienceState = { scope: 'public' };

    export let type: Type;
    export let actions: Studio.Actions = {
        saveDraft: (manuallySaved: boolean) => {
            return saveDraft(manuallySaved, state);
        },
        shouldDraft: async () => shouldSave($state),
        publish: () => $state.mode = 'publish',
    }

    function createInitialState<T extends Type>(type: T): State<T> {
        return {
            mode: "edit",
            audience,
            type,
            ...(type === "article" ? { article: new NDKArticle($ndk), withPreview: true, broadPreviewPublish: true } : {}),
            ...(type === "video" ? { video: new NDKVideo($ndk) } : {}),
            ...(type === "thread" ? { thread: {} as Thread } : {}),
        } as State<T>;
    }

    // Initialize the store with the correctly typed state
    const state = writable(createInitialState(type));

    $: if (draftId) {
        const newState = createStateFromDraftId(draftId, checkpointId) as State<Type>;
        if (newState) {
            newState.draftId = draftId;
            state.set(newState);
            forceReloadAt = Date.now();
        }
    }

    let forceReloadAt = 0;

    let ready = true;

    if (eventId) {
        ready = false;
        $ndk.fetchEvent(eventId).then((e) => {
            if (e) {
                const event = wrapEvent(e) as NDKArticle | NDKVideo;

                state.update((s) => {
                    s.mode = "edit";
                    if (event instanceof NDKArticle) {
                        s.article = event;
                        s.type = "article";
                    } else if (event instanceof NDKVideo) {
                        s.video = event;
                        s.type = "video";
                    }
                    return s;
                });
                
                ready = true;
            }
        });
    }

    setContext('state', state);
</script>

{#if $currentUser}
    <LoadingScreen {ready}>
        <User.Root
            user={$currentUser}
            let:authorUrl
        >
            {#key forceReloadAt}
                <slot
                    {state}
                    {actions}
                    {authorUrl}
                />
            {/key}
        </User.Root>
    </LoadingScreen>
{/if}