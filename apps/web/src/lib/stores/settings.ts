import { getDefaultRelaySet } from '$utils/ndk';
import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';
import { writable } from 'svelte/store';

export const walletType = persist(
	writable<'webln' | 'nip-60' | null>(null),
	createLocalStorage(),
	'wallet-type'
);

export const hasSwiped = persist(
	writable<boolean>(false),
	createLocalStorage(),
	'has-swiped'
);

export const devMode = persist(
	writable<boolean>(false),
	createLocalStorage(),
	'dev-mode'
);

export const addJobButtonsSeen = persist(
	writable<number>(0),
	createLocalStorage(),
	'add-job-buttons-seen'
);

export const welcomeScreenSeen = persist(
	writable<boolean | undefined>(undefined),
	createLocalStorage(),
	'welcome-screen-seen'
);

export const readReceips = persist(
	writable<"anonymous" | undefined>(undefined),
	createLocalStorage(),
	'read-receipts'
);

export const seenOnboardingPromptGridItem = persist(
	writable<boolean | undefined>(undefined),
	createLocalStorage(),
	'seen-onboarding-prompt-grid-item'
);

export const wysiwygEditor = persist(
	writable<boolean>(true),
	createLocalStorage(),
	'wysiwyg'
)

export const seenHighlightUserHelperModal = persist(
	writable<boolean | undefined>(undefined),
	createLocalStorage(),
	'seen-highlight-user-helper-modal'
);

export const publishDraftsToRelays = persist(
	writable<false | string[]>(getDefaultRelaySet().relayUrls),
	createLocalStorage(),
	'publish-drafts-to-relays'
);
