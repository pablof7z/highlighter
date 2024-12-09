<script lang="ts">
	import '../app.css';
	import '@fontsource/spectral';
	import '@fontsource/spectral/300.css';
	import '@fontsource/spectral/300-italic.css';
	import '@fontsource/spectral/500.css';
	import '@fontsource/spectral/500-italic.css';
	import '@fontsource/spectral/600.css';
	import '@fontsource/spectral/600-italic.css';
	import { ndk } from '@/state/ndk';
	import { ModeWatcher } from 'mode-watcher';
	import { NDKPrivateKeySigner } from '@nostr-dev-kit/ndk';
	import { browser } from '$app/environment';

	let { children } = $props();

	if (browser) {
		ndk.once('signer:ready', () => {
			if (ndk.signer instanceof NDKPrivateKeySigner) {
				localStorage.setItem('studio.signer.privatekey', ndk.signer.privateKey!);
			}
		});

		const privateKey = localStorage.getItem('studio.signer.privatekey');
		if (privateKey) {
			ndk.signer = new NDKPrivateKeySigner(privateKey);
		}
	}

	ndk.explicitRelayUrls = ['wss://relay.primal.net'];
	ndk.connect();
</script>

<ModeWatcher />

{@render children()}
