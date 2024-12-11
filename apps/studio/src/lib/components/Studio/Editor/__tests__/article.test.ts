import { describe, it, expect, vi } from 'vitest';
import { EditorState } from '../../state.svelte.ts';
import { NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
import { NDKArticle, NDKDraft } from '@nostr-dev-kit/ndk';

describe('Article publishing', () => {
    it('should delete draft when article is published', async () => {
        // Create a mock draft
        const mockDraft = new NDKDraft();
        mockDraft.delete = vi.fn().mockResolvedValue(true);
        
        // Create editor state with a draft
        const state = new EditorState();
        state.draft = mockDraft;
        state.type = 'article';
        state.title = 'Test Article';
        state.content = 'Test Content';
        
        // Generate and publish the article
        const event = state.generateEvent();
        await event.publish();
        
        // Verify the draft was deleted
        expect(mockDraft.delete).toHaveBeenCalled();
    });
});
