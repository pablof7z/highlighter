import { NDKArticle, NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
import { NDKDraft } from "@nostr-dev-kit/ndk";
import { PostState } from "./index.svelte";
import { ndk } from "@/state/ndk";
import { currentUser } from "@/state/current-user.svelte";

export class ArticleState extends PostState {
    type = 'article';
    
    image = $state('');
    title = $state('');
    summary = $state('');
    content = $state('');
    tags = $state<string[]>([]);
    dTag = $state('');

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
            const draft = event instanceof NDKDraft ? event : NDKDraft.from(event);
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

    /**
     * Generates a publishable event for the article
     * @returns 
     */
    generateEvent() {
        let event: NDKArticle | undefined;
        
        event = new NDKArticle(ndk);
        event.title = this.title;
        event.image = this.image;
        event.summary = this.summary;
        event.tags.push(...this.tags.map(t => ['t', t]));
        event.content = this.content;
        event.dTag = this.dTag;

        console.log('generateEvent', event.rawEvent())

        return event;
    }

    generateEvents() {
        return [this.generateEvent()];
    }

    get shouldSaveDraft(): boolean {
        if (!this.content) return false;
        return true;
    }

    /**
     * Generates a draft event
     * @param manual 
     * @returns 
     */
    public generateDraft() {
        const draft = new NDKDraft(ndk);
        draft.event = this.generateEvent();
        return draft;
    }

    async saveDraft(manual: boolean = false) {
        const draftExisted = !!this.draft;
        const draftEvent = this.generateDraft();
        const isCheckpoint = !manual && draftExisted;

        if (isCheckpoint) {
            draftEvent.checkpoint = this.draft;
        } else if (draftExisted) {
            if (!this.draft) throw new Error('We expected to have a draft, but there was none');
            draftEvent.dTag = this.draft.dTag;
        }

        // this should never have a recipient since this is not the publishing flow
        // of a proposal -- this is an internal draft
        await draftEvent.save({ publish: true });

        this.changesSinceLastSave = 0;

        if (!isCheckpoint) {
            this.draft = draftEvent;
        }
    }
}
