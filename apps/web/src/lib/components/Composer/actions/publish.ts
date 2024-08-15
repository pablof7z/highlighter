import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
import { State } from "..";
import { get, Writable } from "svelte/store";
import { ndk } from "$stores/ndk";
import { produceRelaySet, produceTags } from "$components/Audience";
import currentUser from "$stores/currentUser";

export function generateEventFromState(state: State): NDKEvent {
    const $ndk = get(ndk);
    const $currentUser = get(currentUser);
    const event = new NDKEvent($ndk);

    event.kind = state.kind || (state.audience.scope === "public" ? NDKKind.Text : NDKKind.GroupNote);
    event.content = state.content?.trim() ?? "";
    event.tags = produceTags(state.audience, "main");
    event.pubkey = $currentUser!.pubkey;

    // add extra tags
    if (state.tags && state.tags.length > 0) {
        event.tags = [...event.tags, ...state.tags];
    }

    // tag reply
    if (state.replyTo) {
        event.tag(state.replyTo, "reply");
        if (state.replyTo.kind !== NDKKind.Text) {
            event.tags.push(["k", state.replyTo.kind!.toString()]);
        }
    }

    // mention event
    if (state.mentionEvent) {
        event.content += `\nnostr:${state.mentionEvent.encode()}`;
        event.tag(state.mentionEvent, "mention", undefined, "q");
        if (state.mentionEvent.kind !== NDKKind.Text) {
            event.tags.push(["k", state.mentionEvent.kind!.toString()]);
        }
    }

    // append attachment URLs
    if (state.attachments && state.attachments.length > 0) {
        event.content += "\n\n" + state.attachments.join('\n');
    }

    return event;
}

export default async function (
    state: Writable<State>,
) {
    const $state = get(state);
    const event = generateEventFromState($state);

    const relaySet = await produceRelaySet($state.audience, event);

    await event.sign();
    
    event.publish(relaySet);

    $state.dispatch("publish", event);
}
