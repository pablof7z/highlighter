import { NDKEvent, type Hexpubkey, type NDKUser, type NostrEvent } from "@nostr-dev-kit/ndk";
import { ndk } from "@/state/ndk";
import { dvmSchedule, NDKDraft, NDKKind, NDKRelaySet } from "@nostr-dev-kit/ndk";
import { currentUser } from "@/state/current-user.svelte";

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

    getRecipient(): NDKUser | undefined {
        const user = currentUser();
        if (this.proposalRecipient && this.proposalRecipient !== user?.pubkey) {
            return ndk.getUser({ pubkey: this.proposalRecipient });
        }

        return undefined;
    }

    generateEvents(): NDKEvent[] {
        throw new Error('Not implemented');
    }

    generateDraft(): NDKDraft {
        throw new Error('Not implemented');
    }

    async saveDraft(manual: boolean = false) {
        throw new Error('Not implemented');
    }

    async publish(): Promise<NDKEvent[]> {
        const relaySet = NDKRelaySet.fromRelayUrls(this.relays, ndk);

        if (this.proposalRecipient) {
            const draft = this.generateDraft();
            const recipient = this.getRecipient();
            await draft.save({ publish: true, recipient });
            return [draft];
        } else if (this.publishAt) {
            const events = this.generateEvents();
            for (const event of events) {   
                const dvmUser = ndk.getUser({npub: 'npub1shpq6dmqaa8pjas8rftflvmr7nlssm9fqanflw23vlxu2vzexngslu90nm'});
                event.created_at = Math.floor(new Date(this.publishAt).getTime() / 1000);
                await event.sign();
                const confirm = await dvmSchedule(event, dvmUser, undefined, true, 3000);
                if (confirm) {
                    deleteDrafts(this);
                }
            }

            return events;
        } else {
            const events = this.generateEvents();
            for (const event of events) {
                await event.publish(relaySet);
            }
            deleteDrafts(this);

            return events;
        }
    }

    // generateDraft() {
    //     const draft = new NDKDraft(ndk);

	// 	const event = this.generateEvents()[0];
    //     this.draft.event = event;
        
    //     console.log('generated event for draft', event.rawEvent())

    //     // always generate the recipient tagx
    //     let recipient = this.proposalRecipient;
    //     // this.draft.tagValue('p');

    //     // TODO: or if we are no the author of the draft, perhaps we should tag them?
        
    //     const recipientUser = recipient ? ndk.getUser({ pubkey: recipient }) : undefined;
    //     return draft;
    // }

    get shouldSaveDraft(): boolean {
        throw new Error('Not implemented');
    }
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