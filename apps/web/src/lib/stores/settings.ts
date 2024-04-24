import { persist, createLocalStorage } from '@macfja/svelte-persistent-store';
import { writable } from 'svelte/store';

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