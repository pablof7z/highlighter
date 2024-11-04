<script lang="ts">
	import { onMount } from 'svelte';
	import '../app.postcss';
	import { prepareSession } from '$stores/session';
	import { configureFeNDK } from '$utils/ndk';
	// import { pwaInfo } from 'virtual:pwa-info';
	import "@fontsource/spectral";
	import "@fontsource/spectral/300.css";
	import "@fontsource/spectral/300-italic.css";
	import "@fontsource/spectral/600.css";
	import "@fontsource/spectral/600-italic.css";
	import { browser } from '$app/environment';
	import { browserSetup } from './browser-session-setup.js';
	import createDebug from 'debug';
	import currentUser from '$stores/currentUser';
	import { appMobileView } from '$stores/app';
	import { isMobileBuild, isPhone } from '$utils/view/mobile';
	import { initStoreEvent } from '$stores/events';
	import { ModeWatcher } from "mode-watcher";
	import { ndk } from '$stores/ndk';
	import AppShell from '$components/App/Shell.svelte';
	import { layout } from '$stores/layout';
	import { initialize } from '@capacitor-community/safe-area';

	initialize();

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

	// let webManifestLink: string;
	// $: webManifestLink = pwaInfo ? pwaInfo.webManifest.linkTag : ''

	let mounted = browser ? false : true;

	$: if (!$currentUser && browser) {
		const browserSetupPromise = browserSetup(false);
		configureFeNDK().then(async () => {
			await browserSetupPromise;
		});
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
</script>

<svelte:head>
	{#if $layout.title}
		<title>{$layout.title}</title>
	{/if}
</svelte:head>

<!-- <NetworkHandler /> -->

<ModeWatcher />

	<AppShell>
		<slot />
	</AppShell>