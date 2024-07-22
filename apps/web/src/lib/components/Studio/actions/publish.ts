import { ndk } from "$stores/ndk";
import { Thread } from "$utils/thread";
import { NDKEvent, NDKRelay, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { GroupId, Relays } from "..";

function getRelaySet(publishInGroups?: Map<GroupId, Relays>): NDKRelaySet | undefined {
    const $ndk = get(ndk);
    const urls = new Set<string>();

    if (publishInGroups) {
        for (const [groupId, relays] of publishInGroups) {
            for (const url of relays) {
                urls.add(url);
            }
        }
    }

    if (urls.size === 0) return undefined;

    return NDKRelaySet.fromRelayUrls(Array.from(urls), $ndk);
}

function getTags(publishInGroups?: Map<GroupId, Relays>): NDKTag[] {
    const tags: NDKTag[] = [];

    if (publishInGroups) {
        for (const [groupId, relays] of publishInGroups) {
            tags.push(
                [ "h", groupId, ...relays ]
            );
        }
    }

    return tags;
}

export async function publish(
    event?: NDKEvent,
    thread?: Thread,
    publishInGroups?: Map<GroupId, Relays>,
    publishAt?: Date,
) {
    const relaySet = getRelaySet(publishInGroups);

    const tags = getTags(publishInGroups);

    if (event) {
        publishEvent(event, relaySet, tags, publishAt);
    }
}

export async function publishEvent(
    event: NDKEvent,
    relaySet: NDKRelaySet | undefined,
    tags: NDKTag[],
    publishAt?: Date,
): Promise<NDKEvent> {
    const $ndk = get(ndk);
    
    event.created_at = undefined;
    event.id = "";
    if (publishAt) {
        event.created_at = Math.floor(publishAt.getTime() / 1000);
    }
    event.tags = event.tags.filter(tag => tag[0] !== "h");
    event.tags.push(...tags);
    
    await event.sign();

    const rest = await event.publish(relaySet);
    console.log('published', relaySet?.relayUrls, event.rawEvent())
    console.log(rest);

    return event;
}


export async function publishThread(
    thread: Thread,
    publishAt?: Date,
) {
    const $ndk = get(ndk);

    console.log("Publishing thread", thread);
}