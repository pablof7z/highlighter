import { ndk } from "$stores/ndk";
import { Thread } from "$utils/thread";
import { calculateRelaySetFromEvent, getRelayListForUser, NDKEvent, NDKRelay, NDKRelaySet, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
import { get, Writable } from "svelte/store";
import currentUser from "$stores/currentUser";
import * as Studio from "./index.js";
import { produceRelaySet, produceTags } from "$components/Audience";

// function getTags(
//     publishInGroups?: Map<GroupId, Relays>,
//     scope?: Scope,
//     publishInTiers?: Map<string, NDKSubscriptionTier>,
//     isPreviewForEvent?: NDKEvent
// ): NDKTag[] {
//     const tags: NDKTag[] = [];
//     const isPreview = !!isPreviewForEvent;

//     if (publishInGroups) {
//         for (const [groupId, relays] of publishInGroups) {
//             tags.push(
//                 [ "h", groupId, ...relays ]
//             );
//         }
//     }

//     // non-preview tags
//     if (!isPreview) {
//         console.log('adding non-preview tags')
//         if (scope === "private") {
//             tags.push(['-']);
//         }

//         if (publishInTiers) {
//             for (const [dTag, tier] of publishInTiers) {
//                 tags.push(
//                     [ "f", dTag ]
//                 );
//             }
//         }
//     } else {
//         console.log('adding preview tags')

//         // add a marker to the full version
//         tags.push([ "full", isPreviewForEvent?.tagId() ]);

//         // add which tiers are required
//         if (publishInTiers) {
//             for (const [dTag, tier] of publishInTiers) {
//                 tags.push(
//                     [ "tier", dTag ]
//                 );
//             }
//         }
//     }

//     return tags;
// }

export type PublishingState = 'publishing' | 'published' | false | Error;

export type RelayPublishState = {
    mainEvent: PublishingState;
    previewEvent: PublishingState;
}

function getEventFromState(state: Studio.State): NDKEvent | undefined {
    if (state.type === 'article') return (state as Studio.State<"article">).article;
    if (state.type === 'video') return (state as Studio.State<"video">).video;
}

function getPreviewFromState(state: Studio.State): NDKEvent | undefined {
    if (state.type === 'article') return (state as Studio.State<"article">).preview;
    if (state.type === 'video') return (state as Studio.State<"video">).preview;
}

/**
 * Marks the relays where the event will be published to
 */
function getRelayStore(
    mainRelaySet: NDKRelaySet,
    previewRelaySet: NDKRelaySet | undefined,
) {
    const relays: Record<string, RelayPublishState> = {};
    
    for (const relay of mainRelaySet.relays) {
        if (!relays[relay.url])
            relays[relay.url] = { mainEvent: false, previewEvent: false };

        relays[relay.url].mainEvent = 'publishing';
    }

    if (previewRelaySet) {
        for (const relay of previewRelaySet.relays) {
            if (!relays[relay.url])
                relays[relay.url] = { mainEvent: false, previewEvent: false };

            relays[relay.url].previewEvent = 'publishing';
        }
    }

    console.log({relays})

    return relays;
}

/**
 * Merges the lists of tags, making sure there will be no duplicates
 */
function mergeTags(tags1: NDKTag[], tags2: NDKTag[]): NDKTag[] {
    const tags = new Map<string, NDKTag>();
    for (const tag of tags1) {
        tags.set(tag.join(''), tag);
    }
    for (const tag of tags2) {
        tags.set(tag.join(''), tag);
    }
    return Array.from(tags.values());
}

/**
 * 
 * @param state State of the studio
 * @param relays Store where information about the publishing process will be stored
 * @returns 
 */
export async function publish(
    state: Studio.State,
    relays: Writable<Record<string, RelayPublishState>>
) {
    let mainEvent: NDKEvent = getEventFromState(state)!;
    let previewEvent: NDKEvent | undefined = getPreviewFromState(state);

    const mainRelaySet = await produceRelaySet(state.audience, mainEvent);
    let previewEventRelaySet: NDKRelaySet | undefined;

    if (previewEvent) {
        previewEventRelaySet = await produceRelaySet(state.audience, previewEvent);
    }
    
    const mainEventTags = produceTags(state.audience);
    mainEvent.tags = mergeTags(mainEvent.tags, mainEventTags);
    
    // TODO: Add tags to preview event

    relays.set(getRelayStore(mainRelaySet, previewEventRelaySet));

    return publishEvents(relays, mainEvent, previewEvent, mainRelaySet, previewEventRelaySet);

    // return await publishEvents(
    //     finalEvent,
    //     finalPreview,
    //     mainEventRelaySet,
    //     previewEventRelaySet
    // )
}

export async function finalizeEvent(
    event: NDKEvent,
    tags: NDKTag[],
    publishAt?: Date,
    scope?: Scope
): Promise<NDKEvent> {
    event.created_at = undefined;
    event.id = "";
    if (publishAt) {
        event.created_at = Math.floor(publishAt.getTime() / 1000);
    }

    const tagsToRemove = new Set([ "h", "tier", "f", "full", "-" ]);
    event.tags = event.tags.filter(t => tagsToRemove.has(t[0]) === false);
    event.tags.push(...tags);
    
    await event.sign();

    return event;
}

export async function publishEvents(
    relays: Writable<Record<string, RelayPublishState>>,
    mainEvent: NDKEvent,
    previewEvent?: NDKEvent,
    mainEventRelaySet?: NDKRelaySet,
    previewEventRelaySet?: NDKRelaySet
) {
    const $ndk = get(ndk);

    const updateStatus = (type: keyof RelayPublishState, status: PublishingState, relay: NDKRelay) => {
        if (!relay?.url) {
            console.trace('called failed without relay', relay)
            return;
        }
        
        relays.update($relays => {
            const relayUrl = relay.url;
            if (!$relays[relayUrl]) $relays[relayUrl] = { mainEvent: false, previewEvent: false };
            $relays[relayUrl][type] = status;
            return $relays;
        });
    }

    const onEventPublish = (type: keyof RelayPublishState) => (relay: NDKRelay) => {
        updateStatus(type, 'published', relay);
    }

    const onPublishFail = (type: keyof RelayPublishState) => (relay: NDKRelay, error: Error) => {
        updateStatus(type, error, relay);
    }

    mainEvent.on("relay:published", onEventPublish('mainEvent'));
    mainEvent.on("relay:publish:failed", onPublishFail('mainEvent'));
    
    const rest = await mainEvent.publish(mainEventRelaySet, 5000);

    if (previewEvent) {
        throw new Error("Preview not implemented");
        // const previewRest = await preview.publish(previewEventRelaySet);
        // console.log('published preview', previewEventRelaySet?.relayUrls, preview.rawEvent())
        // console.log(previewRest);
    }

    return rest;
}


// export async function publishThread(
//     thread: Thread,
//     publishInGroups?: Map<GroupId, Relays>,
//     publishAt?: Date,
//     publishScope?: Scope,
//     publishInTiers?: Map<string, NDKSubscriptionTier>,
//     relaySet?: NDKRelaySet
// ) {
//     const $ndk = get(ndk);

//     console.log("Publishing thread", $thread);
// }
