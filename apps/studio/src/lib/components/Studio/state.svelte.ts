import { currentUser } from "@/state/current-user.svelte";
import { ndk } from "@/state/ndk";
import { dvmSchedule, NDKArticle, NDKDraft, NDKEvent, NDKKind, NDKRelaySet, type Hexpubkey, type NostrEvent } from "@nostr-dev-kit/ndk";
import type { Editor } from "svelte-tiptap";

export type EditorType = 'article' | 'thread';

export type ValidationError = 'missing-relays' | 'missing-title' | 'missing-image' | 'missing-summary' | 'missing-content' | 'missing-notes';

export class PostState {
    relays = $state<string[]>([]);
    draft = $state<NDKDraft | null>(null);
    publishAt = $state<Date | null>(null);
    proposalRecipient = $state<Hexpubkey | undefined>(undefined);
    changesSinceLastSave = $state(0);

    /**
     * This is some kind of signature that allows observers to detect changes
     * without knowing the internal structure of what the state looks like.
     * (mostly for the draft button)
     */
    stateSignature = $state('');

    constructor(props?: Partial<PostState>) {
        this.relays = props?.relays ?? ndk.pool.connectedRelays().map((r) => r.url);
    }

    validate(): ValidationError[] {
        console.log('validating', this);
        if (this.relays.length === 0) {
            return ['missing-relays'];
        }

        return [];
    }

    generateEvents(): NDKEvent[] {
        throw new Error('Not implemented');
    }

    generateDraft() {
        debugger
        this.draft ??= new NDKDraft(ndk);

		const event = this.generateEvents()[0];
        this.draft.event = event;
        
        console.log('generated event for draft', event.rawEvent())

        // always generate the recipient tagx
        let recipient = this.proposalRecipient;
        // this.draft.tagValue('p');

        // TODO: or if we are no the author of the draft, perhaps we should tag them?
        
        const recipientUser = recipient ? ndk.getUser({ pubkey: recipient }) : undefined;
        
		this.draft.save({ publish: true, recipient: recipientUser })
    }

    get shouldSaveDraft(): boolean {
        throw new Error('Not implemented');
    }

    async saveDraft(manual: boolean = false) {
        throw new Error('Not implemented');
    }
}

export class ArticleState extends PostState {
    type = 'article';
    
    image = $state('');
    title = $state('');
    summary = $state('');
    content = $state('');
    tags = $state<string[]>([]);
    dTag = $state('');
    editor = $state<Editor | null>(null);

    stateSignature = $derived(this.content);
    
    constructor(props?: Partial<ArticleState>) {
        super(props);
    }

    validate() {
        const errors = super.validate();
        if (this.title.length === 0) errors.push('missing-title');
        if (this.summary.length === 0) errors.push('missing-summary');
        if (this.content.length === 0) errors.push('missing-content');
        if (!this.image) errors.push('missing-image');
        return errors;
    }

    static async from(event: NDKEvent): Promise<ArticleState> {
        let state = new ArticleState();

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
                state = await ArticleState.from(e);
                state.draft = draft;
                console.log('draft', draft.tags);
            }

            const pTag = draft.tagValue('p');
            if (pTag && pTag !== user?.pubkey) {
                state.proposalRecipient = pTag;
            }
        }

        return state;
    }

    generateEvents() {
        let event: NDKArticle | undefined;
        
        event = new NDKArticle(ndk);
        event.title = this.title;
        event.image = this.image;
        event.summary = this.summary;
        event.tags.push(...this.tags.map(t => ['t', t]));
        event.content = this.content;
        event.dTag = this.dTag;

        console.log('generating events', event.rawEvent());

        return [event];
    }

    get shouldSaveDraft(): boolean {
        if (!this.content) return false;
        return true;
    }

    async saveDraft(manual: boolean = false) {
        const draftExisted = !!this.draft;
        let isPrimaryDraft = false;
        let draftEvent: NDKDraft;
        
        // save as the primary draft when
        // - we are saving manually
        // - this is the first time we're saving
        if (manual || !draftExisted) {
            isPrimaryDraft = true;
            draftEvent = new NDKDraft(ndk);
        } else {
            draftEvent = this.draft!;
        }

        const event = this.generateEvents()[0];
        draftEvent.event = event;
        
        console.log('saving draft', { isPrimaryDraft, draftExisted, event: event.rawEvent(), draft: draftEvent.rawEvent() });

        await draftEvent.save({ publish: true });
        this.changesSinceLastSave = 0;
        if (isPrimaryDraft) this.draft = draftEvent;
    }
}

export class ThreadState extends PostState {
    type = 'thread';
    notes = $state<string[]>([]);
    
    constructor() {
        super();
    }

    validate() {
        const errors = super.validate();
        if (this.notes.length === 0) errors.push('missing-content');
        return errors;
    }
}


/**
 * Publishes the event and deletes the draft(s) if they exist
 * @param state 
 */
export async function publish(state: PostState): Promise<NDKEvent | NDKDraft> {
    const events = state.generateEvents();
    const relaySet = NDKRelaySet.fromRelayUrls(state.relays, ndk);

    if (state.proposalRecipient) {
        await state.generateDraft();
        return state.draft!;
    } else if (state.publishAt) {
        for (const event of events) {   
            const dvmUser = ndk.getUser({npub: 'npub1shpq6dmqaa8pjas8rftflvmr7nlssm9fqanflw23vlxu2vzexngslu90nm'});
            event.created_at = Math.floor(new Date(state.publishAt).getTime() / 1000);
            await event.sign();
            const confirm = await dvmSchedule(event, dvmUser, undefined, true, 3000);
            if (confirm) {
                deleteDrafts(state);
            }
        }
    } else {
        for (const event of events) {
            await event.publish(relaySet);
        }
        deleteDrafts(state);
    }

    return events[0];
}

async function deleteDrafts(state: PostState) {
    if (!state.draft) return;

    // Get checkpoints
    // TODO: Need to check on the draft relays
    const checkpoints = await ndk.fetchEvents({
        kinds: [NDKKind.DraftCheckpoint],
        "#a": [state.draft.tagId()],
        authors: [state.draft.pubkey]
    });

    await state.draft.delete();

    if (checkpoints.size > 0) {
        const deleteEvent = new NDKEvent(ndk, {
            kind: NDKKind.EventDeletion,
            tags: Array.from(checkpoints).map(c => c.tagReference())
        } as NostrEvent);

        await deleteEvent.sign();

        await deleteEvent.publish();
    }
}