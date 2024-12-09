import { ndk } from "@/state/ndk";
import { NDKArticle, NDKDraft, NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";

export class EditorState {
    type = $state<'article'>("article");
    
    title = $state('');
    summary = $state('');
    content = $state('');

    dTag = $state('');

    draft = $state<NDKDraft | null>(null);

    relays = $state<string[]>([]);

    static async from(event: NDKEvent): Promise<EditorState> {
        let state = new EditorState();
        
        if (event.kind === NDKKind.Article) {
            const article = NDKArticle.from(event);
            state.title = article.title ?? '';
            state.summary = article.summary ?? '';
            state.content = article.content ?? '';
            state.dTag = article.dTag ?? '';
        } else if (event.kind === NDKKind.Draft) {
            const draft = NDKDraft.from(event);
            const e = await draft.getEvent();
            if (e) {
                state = await EditorState.from(e);
                state.draft = draft;
            }
        }

        return state;
    }

    generateEvent() {
        let event: NDKArticle | undefined;
        
        if (this.type === 'article') {
            event = new NDKArticle(ndk);
            event.title = this.title;
            event.summary = this.summary;
            event.content = this.content;
        }

        if (!event) throw new Error('Event not created' + this.type);

        event.dTag = this.dTag;

        console.log(event.rawEvent());

        return event;
    }
}