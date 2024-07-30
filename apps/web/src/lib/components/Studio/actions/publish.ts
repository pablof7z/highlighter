import { ndk } from "$stores/ndk";
import { Thread } from "$utils/thread";
import { calculateRelaySetFromEvent, getRelayListForUser, NDKEvent, NDKRelay, NDKRelaySet, NDKSubscriptionTier, NDKTag } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { GroupId, Relays, Scope } from "..";
import currentUser from "$stores/currentUser";

export async function getRelaySet(
    event: NDKEvent,
    publishInGroups?: Map<GroupId, Relays>,
    scope?: Scope,
    isPreview = false
): Promise<NDKRelaySet> {
    const $ndk = get(ndk);
    const urls = new Set<string>();

    if (publishInGroups && publishInGroups.size > 0) {
        for (const [groupId, relays] of publishInGroups) {
            for (const url of relays) {
                urls.add(url);
            }
        }

        if (urls.size === 0) {
            console.log('no relays found for groups', publishInGroups);
            throw new Error("No relays found for groups");
        }
    }

    if (urls.size === 0) {
        return await calculateRelaySetFromEvent($ndk, event)
    }

    // if we are returning an explicit list of relays we need to include
    // the user's own relays if the scope is public
    
    if (scope === "public" || isPreview) {
        const $ndk = get(ndk);
        const $currentUser = get(currentUser);
        if ($currentUser) {
            const userRelays = await getRelayListForUser($currentUser.pubkey, $ndk);
            // add the user's relays to the list
            for (const url of userRelays.relays) {
                urls.add(url);
            }
        }
    }

    return NDKRelaySet.fromRelayUrls(Array.from(urls), $ndk);
}

function getTags(
    publishInGroups?: Map<GroupId, Relays>,
    scope?: Scope,
    publishInTiers?: Map<string, NDKSubscriptionTier>,
    isPreviewForEvent?: NDKEvent
): NDKTag[] {
    const tags: NDKTag[] = [];
    const isPreview = !!isPreviewForEvent;

    if (publishInGroups) {
        for (const [groupId, relays] of publishInGroups) {
            tags.push(
                [ "h", groupId, ...relays ]
            );
        }
    }

    // non-preview tags
    if (!isPreview) {
        console.log('adding non-preview tags')
        if (scope === "private") {
            tags.push(['-']);
        }

        if (publishInTiers) {
            for (const [dTag, tier] of publishInTiers) {
                tags.push(
                    [ "f", dTag ]
                );
            }
        }
    } else {
        console.log('adding preview tags')

        // add a marker to the full version
        tags.push([ "full", isPreviewForEvent?.tagId() ]);

        // add which tiers are required
        if (publishInTiers) {
            for (const [dTag, tier] of publishInTiers) {
                tags.push(
                    [ "tier", dTag ]
                );
            }
        }
    }

    return tags;
}

export async function publish(
    event: NDKEvent,
    preview?: NDKEvent,
    publishInGroups?: Map<GroupId, Relays>,
    publishAt?: Date,
    scope?: Scope,
    publishInTiers?: Map<string, NDKSubscriptionTier>,
    mainEventRelaySet?: NDKRelaySet,
    previewEventRelaySet?: NDKRelaySet
) {
    const tags = getTags(
        publishInGroups,
        scope,
        publishInTiers
    );

    const finalEvent = await finalizeEvent(event, tags, publishAt);
    let finalPreview: NDKEvent | undefined;

    if (preview) {
        const previewTags = getTags(
            publishInGroups,
            scope,
            publishInTiers,
            finalEvent
        );
        try {
            finalPreview = await finalizeEvent(preview, previewTags, publishAt);
        } catch (e) {
            console.error('Error finalizing preview', e);
        }
    }

    console.log('main event', finalEvent.rawEvent());
    console.log('preview event', finalPreview?.rawEvent());

    return await publishEvents(
        finalEvent,
        finalPreview,
        mainEventRelaySet,
        previewEventRelaySet
    )
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
    event: NDKEvent,
    preview?: NDKEvent,
    mainEventRelaySet?: NDKRelaySet,
    previewEventRelaySet?: NDKRelaySet
) {
    const $ndk = get(ndk);

    const rest = await event.publish(mainEventRelaySet, 5000);

    if (preview) {
        const previewRest = await preview.publish(previewEventRelaySet);
        console.log('published preview', previewEventRelaySet?.relayUrls, preview.rawEvent())
        console.log(previewRest);
    }

    return rest;
}


export async function publishThread(
    thread: Thread,
    publishAt?: Date,
) {
    const $ndk = get(ndk);

    console.log("Publishing thread", thread);
}