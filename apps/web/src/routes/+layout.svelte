<script lang="ts">
	import { onMount } from 'svelte';
	import '../app.postcss';
	import { Modals, closeModal } from 'svelte-modals'
	import { fade } from 'svelte/transition';
	import { Toaster, bunkerNDK, ndk, user } from '@kind0/ui-common';
	import { login } from '$utils/login';
	import { prepareSession } from '$stores/session';

	onMount(async () => {
		window?.addEventListener('bc:connected', (e) => {
			console.log('bc:connected', e);
		});

        try {
			const keyMethod = localStorage.getItem('nostr-key-method');
            $ndk.connect();

			if (keyMethod === 'nip07') {
				await loginNip07();
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
		const u = await login($ndk, $bunkerNDK, 'nip07');
		if (u) $user = u;
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

<Toaster />
