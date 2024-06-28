<script lang="ts">
	import { onMount } from 'svelte';
	import '../app.postcss';
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
	import currentUser from '$stores/currentUser';
	import MobileAppShell from '$components/PageElements/Mobile/AppShell.svelte';
	import { appMobileView } from '$stores/app';
	import { isMobileBuild, isPhone } from '$utils/view/mobile';
	import { initStoreEvent } from '$stores/events';
	import { ModeWatcher } from "mode-watcher";
	import { ndk } from '$stores/ndk';
	import OnboardingScreen from '$views/Mobile/Pages/OnboardingScreen.svelte';
	import { page } from '$app/stores';
	

	// import { defineCustomElements } from "@ionic/pwa-elements/loader";
	// import { setupIonicSvelte } from "ionic-svelte";
	// import { PushNotifications } from '@capacitor/push-notifications';

	// const registerNotifications = async () => {
	// 	let permStatus = await PushNotifications.checkPermissions();

	// 	if (permStatus.receive === 'prompt') {
	// 		permStatus = await PushNotifications.requestPermissions();
	// 	}

	// 	if (permStatus.receive !== 'granted') {
	// 		throw new Error('User denied permissions!');
	// 	}

	// 	await PushNotifications.register();
	// }

	// registerNotifications().catch(console.error);

	const d = createDebug('HL:layout');
	
	/** Mobile concerns */
	$appMobileView = isMobileBuild() || isPhone();
	
	// $: if ($appMobileView && browser) {
	// 	setupIonicSvelte();
	// 	defineCustomElements(window);
	// }

	let webManifestLink: string;
	$: webManifestLink = pwaInfo ? pwaInfo.webManifest.linkTag : ''

	let hasJwt = false;
	let mounted = browser ? false : true;

	$: if (!$currentUser && browser) {
		const browserSetupPromise = browserSetup(false);
		configureFeNDK().then(async () => {
			await browserSetupPromise;
		});

		// hasJwt = !!$jwt && document.cookie.includes('jwt=');
	}

	onMount(async () => {
		initStoreEvent($ndk);
		window.addEventListener('resize', setResponsiveView);

		if ($ndk.cacheAdapter?.onReady && !$ndk.cacheAdapter?.ready) {
			$ndk.cacheAdapter.onReady(() => {
				mounted = true
			});
		} else {
			mounted = true;
		}
    });

	let finalizingLogin = false;

	// let shouldOpenWelcomeModal: boolean | undefined = undefined;
	// $: if (mounted && $userProfile && !$welcomeScreenSeen) {
	// 	const date = Math.floor(Date.now() / 1000) - 600;
	// 	if ($userProfile.created_at >= date) {
	// 		shouldOpenWelcomeModal = true;
	// 	} else {
	// 		// Not a new nostr user; no need to welcome them since they didn't create their account just now
	// 		$welcomeScreenSeen = true;
	// 	}
	// }

	// $: if (shouldOpenWelcomeModal) {
	// 	openModal(SignupModal, { mode: 'welcome' });
	// }

	// $: if (mounted && !hasJwt) {
	// 	hasJwt = !!$jwt && document.cookie.includes('jwt=');
	// 	d(`hasJwt`, hasJwt);
	// }

	$: if (mounted && $currentUser && $ndk.signer && !hasJwt && !finalizingLogin) {
		finalizingLogin = true;
		try {
			finalizeLogin();
		} catch {}
	}

	let sessionPreparationStarted = false;

	$: if (!sessionPreparationStarted && !!$currentUser) {
		sessionPreparationStarted = true;
		prepareSession();
	}

	function setResponsiveView() {
		if (isMobileBuild()) {
			$appMobileView = true;
			return;
		}

		if (!document) return;

		// if screen size is less than 768px, set mobile view
		if (document.documentElement.clientWidth < 768) {
			$appMobileView = true;
		} else {
			$appMobileView = false;
		}
	}

	export let data;

	console.log('layout.svelte', data);
</script>

<!-- <NetworkHandler /> -->

<ModeWatcher />

{#if $appMobileView}
	<MobileAppShell>
		{#if !$currentUser && !$page.url.pathname.startsWith("/mobile")}
			<OnboardingScreen />
		{:else}
			<slot />
		{/if}
	</MobileAppShell>
{:else}
	<LoadingScreen ready={mounted}>
		<AppShell>
			<slot />
		</AppShell>
	</LoadingScreen>
{/if}