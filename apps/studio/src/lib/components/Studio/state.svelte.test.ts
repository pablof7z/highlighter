import { PostState, ArticleState, ThreadState, publish } from './state.svelte';
import { NDKEvent, NDKDraft, NDKKind } from '@nostr-dev-kit/ndk';

jest.mock('@nostr-dev-kit/ndk', () => ({
    NDKEvent: jest.fn().mockImplementation(() => ({
        sign: jest.fn(),
        publish: jest.fn(),
    })),
    NDKDraft: jest.fn().mockImplementation(() => ({
        save: jest.fn(),
        delete: jest.fn(),
        getEvent: jest.fn().mockResolvedValue(null),
        tagValue: jest.fn().mockReturnValue(''),
    })),
    NDKKind: {
        Article: 'article',
        Draft: 'draft',
        DraftCheckpoint: 'draft-checkpoint',
        EventDeletion: 'event-deletion',
    },
}));

describe('PostState', () => {
    it('should initialize with default values', () => {
        const postState = new PostState();
        expect(postState.relays).toEqual([]);
        expect(postState.draft).toBeNull();
        expect(postState.publishAt).toBeNull();
        expect(postState.proposalRecipient).toBeUndefined();
        expect(postState.changesSinceLastSave).toBe(0);
    });

    it('should validate missing relays', () => {
        const postState = new PostState();
        const errors = postState.validate();
        expect(errors).toContain('missing-relays');
    });
});

describe('ArticleState', () => {
    it('should initialize with default values', () => {
        const articleState = new ArticleState();
        expect(articleState.type).toBe('article');
        expect(articleState.title).toBe('');
        expect(articleState.summary).toBe('');
        expect(articleState.content).toBe('');
        expect(articleState.image).toBe('');
    });

    it('should validate missing fields', () => {
        const articleState = new ArticleState();
        const errors = articleState.validate();
        expect(errors).toContain('missing-title');
        expect(errors).toContain('missing-summary');
        expect(errors).toContain('missing-content');
        expect(errors).toContain('missing-image');
    });
});

describe('ThreadState', () => {
    it('should initialize with default values', () => {
        const threadState = new ThreadState();
        expect(threadState.type).toBe('thread');
        expect(threadState.notes).toEqual([]);
    });

    it('should validate missing content', () => {
        const threadState = new ThreadState();
        const errors = threadState.validate();
        expect(errors).toContain('missing-content');
    });
});

describe('Drafts Functionality', () => {
    it('should generate and save a draft', async () => {
        const articleState = new ArticleState();
        articleState.generateEvents = jest.fn().mockReturnValue([new NDKEvent()]);
        await articleState.saveDraft(true);
        expect(articleState.draft).toBeInstanceOf(NDKDraft);
        expect(articleState.draft?.save).toHaveBeenCalledWith({ publish: true });
    });

    it('should delete drafts', async () => {
        const postState = new PostState();
        postState.draft = new NDKDraft();
        await postState.draft.delete();
        expect(postState.draft.delete).toHaveBeenCalled();
    });
});

describe('ProposalRecipient Functionality', () => {
    it('should generate a draft when proposalRecipient is set', async () => {
        const postState = new PostState();
        postState.proposalRecipient = 'someRecipient';
        postState.generateDraft = jest.fn();
        await publish(postState);
        expect(postState.generateDraft).toHaveBeenCalled();
    });

    it('should not generate a draft when proposalRecipient is not set', async () => {
        const postState = new PostState();
        postState.generateDraft = jest.fn();
        await publish(postState);
        expect(postState.generateDraft).not.toHaveBeenCalled();
    });
});

describe('publish function', () => {
    it('should publish events', async () => {
        const postState = new PostState();
        postState.generateEvents = jest.fn().mockReturnValue([new NDKEvent()]);
        const event = await publish(postState);
        expect(event).toBeInstanceOf(NDKEvent);
    });

    it('should handle draft generation', async () => {
        const postState = new PostState();
        postState.proposalRecipient = 'someRecipient';
        postState.generateDraft = jest.fn();
        await publish(postState);
        expect(postState.generateDraft).toHaveBeenCalled();
    });
});