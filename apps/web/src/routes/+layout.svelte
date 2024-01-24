<script lang="ts">
	import { onMount } from 'svelte';
	import '../app.postcss';
	import { Toaster, bunkerNDK, ndk, pageDrawerToggle, rightSidebar, user } from '@kind0/ui-common';
	import { finalizeLogin, login } from '$utils/login';
	import { debugMode, prepareSession, jwt, loginState } from '$stores/session';
	import { configureFeNDK } from '$utils/ndk';
	import { pwaInfo } from 'virtual:pwa-info';
	import AppShell from '$components/PageElements/AppShell.svelte';
	import "@fontsource/lora";

	let webManifestLink: string;
	$: webManifestLink = pwaInfo ? pwaInfo.webManifest.linkTag : ''

	let mounted = false;

	onMount(async () => {
		mounted = true;
		hasJwt = !!$jwt;
		await configureFeNDK();

        try {
			const keyMethod = localStorage.getItem('nostr-key-method');
			loginState.set("logging-in");

			if (keyMethod === 'nip07') {
				await login($ndk, $bunkerNDK, 'nip07');
			} else if (keyMethod === 'nip46') {
				await login($ndk, $bunkerNDK, 'nip46');
			} else if (!keyMethod) {
				let nip07Attempts = 0;
				const nip07Attempt = setInterval(() => {
					if (nip07Attempts > 10) {
						clearInterval(nip07Attempt);
						return;
					}

					if ($ndk.signer) {
						clearInterval(nip07Attempt);
						return;
					}

					nip07Attempts++;
					if (window.nostr) {
						login($ndk, $bunkerNDK, 'nip07');
						clearInterval(nip07Attempt);
					}
				}, 20);
			}
        } catch (e) {
            console.error(`layout error`, e);
        }
    });

	let hasJwt = false;
	let finalizingLogin = false;

	$: if (mounted && !hasJwt) {
		hasJwt = !!$jwt;
		console.log(`hasJwt`, hasJwt);
	}

	$: if (mounted && $user && $ndk.signer && !hasJwt && !finalizingLogin) {
		finalizingLogin = true;
		finalizeLogin();
	}

	let sessionPreparationStarted = false;

	$: if (!sessionPreparationStarted && !!$user) {
		sessionPreparationStarted = true;
		prepareSession();
	}
</script>

<svelte:head>
	{@html webManifestLink}
</svelte:head>

<AppShell>
	<slot />
</AppShell>