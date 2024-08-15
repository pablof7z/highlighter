import { ndk } from "$stores/ndk";
import { NDKArticle, NDKEvent, NDKRelay, NDKRelaySet, NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";
import { get, Writable } from "svelte/store";
import * as Studio from "../index.js";
import * as Audience from "$components/Audience";
import { generatePreviewContent } from "$utils/preview";

export type PublishingState = 'publishing' | 'published' | false | Error;

export type RelayPublishState = {
    mainEvent: PublishingState;
    previewEvent: PublishingState;
}

function getOrGeneratePreviewFromState(state: Studio.State<Studio.PreviewableTypes>): NDKEvent {
    let previewEvent: NDKArticle | NDKVideo | NDKEvent | undefined = Studio.getPreviewFromState(state);
    previewEvent ??= generatePreviewEventFromState(state);
    
    return previewEvent;
}

function generatePreviewEventFromState(state: Studio.State<Studio.PreviewableTypes>): NDKArticle | NDKVideo {
    let preview: NDKArticle | NDKVideo | undefined;
    const $ndk = get(ndk);

    switch (state.type) {
        case 'article': {
            const mainEvent = Studio.getEventFromState(state) as NDKArticle;
            preview = new NDKArticle($ndk);
            preview.title = mainEvent.title;
            preview.image = mainEvent.image;
            preview.content = generatePreviewContent(mainEvent);

            if (state.previewAppend) {
                preview.content += '\n' + state.previewAppend;
            }
            
            break;
        }
        case 'video': {
            const mainEvent = Studio.getEventFromState(state) as NDKVideo;
            preview = new NDKVideo($ndk);
            preview.title = mainEvent.title;
            preview.thumbnail = mainEvent.thumbnail;
            break;
        }
        default:
            throw new Error("Invalid state type" + state.type);
    } 

    return preview;
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
    state: Writable<Studio.State<Studio.Type>>,
    relays: Writable<Record<string, RelayPublishState>>
) {
    debugger
    const $state = get(state);
    let mainEvent: NDKEvent = Studio.getEventFromState($state)!;
    let previewEvent: NDKEvent | undefined = getOrGeneratePreviewFromState($state);
    $state.preview = previewEvent;

    if ($state.audience.scope === 'private') {
        // Magical NIP-70 tag
        mainEvent.tags.push(['-']);

        // if we were requested to not publish the preview broadly, we also add the NIP-70 tag
        if ($state.broadPreviewPublish === false && previewEvent) {
            previewEvent.tags.push(['-']);
        }
    }
    
    mainEvent.tags = mergeTags(mainEvent.tags, Audience.produceTags($state.audience, 'main'));

    // sign events
    await mainEvent.sign();
    
    if (previewEvent) {
        previewEvent.tags = mergeTags(previewEvent.tags, Audience.produceTags($state.audience, 'preview'));
        previewEvent.tags.push(["full", mainEvent.tagId()]);
        
        await previewEvent.sign();
    }

    // Event(s) are signed; get relay sets

    const mainRelaySet = await Audience.produceRelaySet($state.audience, mainEvent);

    let previewEventRelaySet: NDKRelaySet | undefined;

    if (previewEvent) {
        let previewAudience: Audience.State = $state.audience;

        // if we are doing broadPreviewPublish, then the scope of the preview is public
        if ($state.broadPreviewPublish)
            previewAudience.scope = 'public';

        previewEventRelaySet = await Audience.produceRelaySet(previewAudience, previewEvent);
    }

    relays.set(getRelayStore(mainRelaySet, previewEventRelaySet));
    
    return publishEvents(relays, mainEvent, previewEvent, mainRelaySet, previewEventRelaySet);
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
        previewEvent.on("relay:published", onEventPublish('previewEvent'));
        previewEvent.on("relay:publish:failed", onPublishFail('previewEvent'));

        await previewEvent.publish(previewEventRelaySet);
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
