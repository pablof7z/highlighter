import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
import { State } from "..";
import { get, Writable } from "svelte/store";
import { ndk } from "$stores/ndk";

export default async function (
    state: Writable<State>,
) {
    const $state = get(state);
    const $ndk = get(ndk);
    const event = new NDKEvent($ndk);
    event.kind = $state.kind;
    event.content = $state.content?.trim() ?? "";

    // add extra tags
    if ($state.tags && $state.tags.length > 0) {
        event.tags = [ ...event.tags, ...$state.tags ];
    }

    // tag reply
    if ($state.replyTo) {
        event.tag($state.replyTo, "reply");
        if ($state.replyTo.kind !== NDKKind.Text)
            event.tags.push(["k", $state.replyTo.kind!.toString()]);
    }

    // mention event
    if ($state.mentionEvent) {
        event.content += `\nnostr:${$state.mentionEvent.encode()}`
        event.tag($state.mentionEvent, "mention", undefined, "q");
        if ($state.mentionEvent.kind !== NDKKind.Text)
            event.tags.push(["k", $state.mentionEvent.kind!.toString()]);
    }

    // append attachment URLs
    if ($state.attachments && $state.attachments.length > 0) {
        event.content += $state.attachments.join('\n');
    }

    await event.sign();
    
    event.publish($state.relaySet);

    $state.dispatch("publish", event);
}