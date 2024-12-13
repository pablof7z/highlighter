import { vi, describe, it, expect, beforeAll, beforeEach } from 'vitest';
import { ArticleState } from "./article.svelte";
import { NDKArticle, NDKDraft, NDKPrivateKeySigner, NDKUser } from '@nostr-dev-kit/ndk';
import { ndk } from '@/state/ndk';

const signer = NDKPrivateKeySigner.generate();
ndk.signer = signer;

const signer2 = NDKPrivateKeySigner.generate();

describe('ArticleState', () => {
    let user1: NDKUser;
    let user2: NDKUser;
    beforeAll(async () => {
        user1 = await signer.user();
        user2 = await signer2.user();
    })
    
    it('should generate a draft', () => {
        const state = new ArticleState();
        const draft = state.generateDraft(false);
        expect(draft).toBeDefined();
    });

    it('should p-tag the recipient\'s pubkey when there is a recipient', () => {
        const state = new ArticleState();
        state.proposalRecipient = user2.pubkey;
        const draft = state.generateDraft(true);
        expect(draft.tagValue('p')).toContain(user2.pubkey);
    });

    describe.only('with a draft proposal from user2 sent to user1', () => {
        let draft: NDKDraft;
        
        beforeEach(async () => {
            const event = new NDKArticle(ndk);
            event.title = 'test';
            draft = new NDKDraft(ndk);
            draft.event = event;
            console.log('draft', draft.rawEvent());
            console.log('key', signer2._privateKey)
            await draft.save({ recipient: user1, signer: signer2, publish: false})
            console.log('draft', draft.rawEvent());
        })

        describe('when user1 saves the draft', () => {
            it('doesnt include the p-tag of the user saving the draft', () => {
                const state = new ArticleState();
                state.draft = draft;
                state.saveDraft(true);
                expect(state.draft?.tagValue('p')).not.toContain(user1.pubkey);
            })
        })
    })
});