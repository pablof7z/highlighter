<script lang="ts">
	import { onMount } from 'svelte';
	import '../app.postcss';
	import { Modals, closeModal } from 'svelte-modals'
	import { fade } from 'svelte/transition';
	import { Toaster, bunkerNDK, ndk, user } from '@kind0/ui-common';
	import { finalizeLogin, login } from '$utils/login';
	import { prepareSession } from '$stores/session';
	import { page } from '$app/stores';
	import { configureFeNDK } from '$utils/configure-fe-ndk';

	const hostname = $page.url.hostname;
	let mounted = false;

	onMount(async () => {
		mounted = true;
		configureFeNDK();

        try {
			const keyMethod = localStorage.getItem('nostr-key-method');

			if (keyMethod === 'nip07') {
				await loginNip07();
			} else if (keyMethod === 'nip46') {
				await login($ndk, $bunkerNDK, 'nip46', hostname);
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
						loginNip07();
						clearInterval(nip07Attempt);
					}
				}, 100);
			}
        } catch (e) {
            console.error(`layout error`, e);
        }
    });

	async function loginNip07() {
		const u = await login($ndk, $bunkerNDK, 'nip07', hostname);
		if (u) $user = u;
	}

	let hasJwt = false;
	let finalizingLogin = false;

	$: if (mounted && !hasJwt) {
		hasJwt = !!localStorage.getItem('jwt');
		console.log(`hasJwt`, hasJwt);
	}

	$: if (mounted && $user && !hasJwt && !finalizingLogin) {
		console.log(`requesting jwt after the fact`);
		finalizingLogin = true;
		finalizeLogin(hostname);
	}

	let sessionPreparationStarted = false;

	$: if (!sessionPreparationStarted && !!$user) {
		sessionPreparationStarted = true;
		prepareSession();
	}
</script>

<Modals>
	<div
		slot="backdrop"
		class="backdrop z-20 fixed"
		on:click={closeModal}
		transition:fade={{ duration: 100 }}></div>
</Modals>

<slot />

<Toaster />

<style lang="postcss">
	.backdrop {
		position: fixed;
		top: 0;
		bottom: 0;
		right: 0;
		backdrop-filter: blur(0.15rem);
		left: 0;
		background: rgba(0,0,0,0.50)
	}

	:global(.toast) {
		@apply fixed bottom-2 right-2;
	}

</style>