import { currentUser } from "@/state/current-user.svelte";
import { ndk } from "@/state/ndk";
import { dvmSchedule, NDKArticle, NDKDraft, NDKEvent, NDKKind, NDKRelaySet, type Hexpubkey, type NostrEvent } from "@nostr-dev-kit/ndk";
import type { Editor } from "svelte-tiptap";

export type EditorType = 'article' | 'thread';

export class EditorState {
    type = $state<EditorType>('article');
    
    image = $state('');
    title = $state('');
    summary = $state('');
    content = $state('');

    tags = $state<string[]>([]);

    dTag = $state('');

    draft = $state<NDKDraft | null>(null);

    relays = $state<string[]>([]);

    publishAt = $state<Date | null>(null);

    proposalRecipient = $state<Hexpubkey | undefined>(undefined);

    editor = $state<Editor | null>(null);

    static async from(event: NDKEvent): Promise<EditorState> {
        let state = new EditorState();

        const user = $derived.by(currentUser);
        
        if (event.kind === NDKKind.Article) {
            const article = NDKArticle.from(event);
            state.title = article.title ?? '';
            state.summary = article.summary ?? '';
            state.image = article.image ?? '';
            state.content = article.content ?? '';
            state.dTag = article.dTag ?? '';
        } else if (event.kind === NDKKind.Draft) {
            const draft = NDKDraft.from(event);
            const e = await draft.getEvent();
            if (e) {
                state = await EditorState.from(e);
                state.draft = draft;
            }

            const pTag = draft.tagValue('p');
            if (pTag && pTag !== user?.pubkey) {
                state.proposalRecipient = pTag;
            }
        }

        return state;
    }

    generateEvent() {
        let event: NDKArticle | undefined;
        
        if (this.type === 'article') {
            event = new NDKArticle(ndk);
            event.title = this.title;
            event.image = this.image;
            event.summary = this.summary;
            event.content = this.content;
        }

        if (!event) throw new Error('Event not created' + this.type);

        event.dTag = this.dTag;

        return event;
    }

    generateDraft(recipient?: Hexpubkey) {
        this.draft ??= new NDKDraft(ndk);

		const event = this.generateEvent();
		this.draft.event = event;

        // if we already have a p-tag in a draft, we assume that's the recipient
        recipient ??= this.draft.tagValue('p');
        
        const recipientUser = recipient ? ndk.getUser({ pubkey: recipient }) : undefined;

        console.log('saving draft for recipient', recipient);
        
		this.draft.save({ publish: true, recipient: recipientUser })
    }
}

/**
 * Publishes the event and deletes the draft(s) if they exist
 * @param state 
 */
export async function publish(state: EditorState): Promise<NDKEvent | NDKDraft> {
    const event = state.generateEvent();
    const relaySet = NDKRelaySet.fromRelayUrls(state.relays, ndk);

    // return new Promise((resolve, reject) => {
    //     setTimeout(() => {
    //         reject("Test")
    //     }, 1000);
    // });

    if (state.proposalRecipient) {
        await state.generateDraft(state.proposalRecipient);
        return state.draft!;
    } else if (state.publishAt) {
        const dvmUser = ndk.getUser({npub: 'npub1shpq6dmqaa8pjas8rftflvmr7nlssm9fqanflw23vlxu2vzexngslu90nm'});
        event.created_at = Math.floor(new Date(state.publishAt).getTime() / 1000);
        await event.sign();
        const confirm = await dvmSchedule(event, dvmUser, undefined, true, 3000);
        if (confirm) {
            deleteDrafts(state);
        }
    } else {
        await event.publish(relaySet);
        deleteDrafts(state);
    }

    return event;
}

async function deleteDrafts(state: EditorState) {
    if (!state.draft) return;

    // Get checkpoints
    // TODO: Need to check on the draft relays
    const checkpoints = await ndk.fetchEvents({
        kinds: [NDKKind.DraftCheckpoint],
        "#a": [state.draft.tagId()],
        authors: [state.draft.pubkey]
    });

    state.draft.content = "This event has been deleted; your client is ignoring the delete request.";
    state.draft.tags = [["deleted"]];
    await state.draft.publishReplaceable();
    
    const deleteEvent = new NDKEvent(ndk, {
        kind: NDKKind.EventDeletion,
        tags: [
            state.draft.tagReference(),
            ["e", state.draft.id],
            ...Array.from(checkpoints).map(c => c.tagReference())
        ]
    } as NostrEvent);

    await deleteEvent.sign();

    await deleteEvent.publish();
}