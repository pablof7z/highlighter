<script lang="ts">
	import { onMount } from 'svelte';
	import '../app.postcss';
	import { ndk, user } from '@kind0/ui-common';
	import { finalizeLogin } from '$utils/login';
	import { prepareSession, jwt, userProfile } from '$stores/session';
	import { configureFeNDK } from '$utils/ndk';
	import { pwaInfo } from 'virtual:pwa-info';
	import AppShell from '$components/PageElements/AppShell.svelte';
	import "@fontsource/lora";
	import "@fontsource/lora/600.css";
	import "@fontsource/lora/600-italic.css";
	import { browser } from '$app/environment';
	import { browserSetup } from './browser-session-setup';
	import createDebug from 'debug';
	import LoadingScreen from '$components/LoadingScreen.svelte';
	import { openModal } from '$utils/modal';
	import SignupModal from '$modals/SignupModal.svelte';
	import { welcomeScreenSeen } from '$stores/settings';
	import currentUser from '$stores/currentUser';
	import { pageHeader } from '$stores/layout';

	const d = createDebug('HL:layout');

	let webManifestLink: string;
	$: webManifestLink = pwaInfo ? pwaInfo.webManifest.linkTag : ''

	let hasJwt = false;
	let mounted = false;

	$: if (!$user && browser) {
		const browserSetupPromise = browserSetup();
		configureFeNDK().then(async () => {
			await browserSetupPromise;
		});

		hasJwt = !!$jwt && document.cookie.includes('jwt=');
	}

	onMount(async () => {
		if ($ndk.cacheAdapter?.onReady && !$ndk.cacheAdapter?.ready) {
			$ndk.cacheAdapter.onReady(() => {
				console.log('Cache adapter ready');
				mounted = true
			});
		} else {
			mounted = true;
		}
    });

	let finalizingLogin = false;

	let shouldOpenWelcomeModal: boolean | undefined = undefined;
	$: if (mounted && $userProfile && !$welcomeScreenSeen) {
		const date = Math.floor(Date.now() / 1000) - 600;
		if ($userProfile.created_at >= date) {
			shouldOpenWelcomeModal = true;
		} else {
			// Not a new nostr user; no need to welcome them since they didn't create their account just now
			$welcomeScreenSeen = true;
		}
	}

	$: if (shouldOpenWelcomeModal) {
		openModal(SignupModal, { mode: 'welcome' });
	}

	$: if (mounted && !hasJwt) {
		hasJwt = !!$jwt && document.cookie.includes('jwt=');
		d(`hasJwt`, hasJwt);
	}

	$: if (mounted && $user && $ndk.signer && !hasJwt && !finalizingLogin) {
		finalizingLogin = true;
		finalizeLogin();
	}

	let sessionPreparationStarted = false;

	$: if (!sessionPreparationStarted && !!$currentUser) {
		sessionPreparationStarted = true;
		prepareSession();
	}

	$: $currentUser = $user;
</script>

<svelte:head>
	{@html webManifestLink}
</svelte:head>

<!-- <NetworkHandler /> -->

<LoadingScreen ready={mounted}>
	<AppShell>
		<slot />
	</AppShell>
</LoadingScreen>