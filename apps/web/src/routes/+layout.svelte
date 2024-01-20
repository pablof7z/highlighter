<script lang="ts">
	import { onMount } from 'svelte';
	import '../app.postcss';
	import { Modals, closeModal } from 'svelte-modals'
	import { fade } from 'svelte/transition';
	import { Toaster, bunkerNDK, ndk, pageDrawerToggle, rightSidebar, user } from '@kind0/ui-common';
	import { finalizeLogin, login } from '$utils/login';
	import { debugMode, prepareSession, jwt, loginState } from '$stores/session';
	import { configureFeNDK } from '$utils/ndk';
	import { Bug } from 'phosphor-svelte';
	import { pwaInfo } from 'virtual:pwa-info';

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

<Modals>
	<div
		slot="backdrop"
		class="backdrop z-20 fixed"
		on:click={closeModal}
		transition:fade={{ duration: 300 }}></div>
</Modals>

<div class="drawer drawer-end">
	<input id="my-drawer-4" type="checkbox" class="drawer-toggle" bind:checked={$pageDrawerToggle} />
	<div class="drawer-content">
		{#key $loginState}
			<slot />
		{/key}
	</div>
	<div class="drawer-side z-50">
		<label for="my-drawer-4" aria-label="close sidebar" class="drawer-overlay"></label>
		<div class="menu w-[90vw] sm:w-[40vw] min-h-full bg-base-200 text-base-content p-8">
			<svelte:component this={$rightSidebar.component} {...$rightSidebar.props} />
		</div>
	</div>
</div>

<Toaster />

<style lang="postcss">
	.backdrop {
		position: fixed;
		top: 0;
		bottom: 0;
		right: 0;
		backdrop-filter: blur(10px);
		left: 0;
		background: rgba(0,0,0,0.50)
	}

	:global(.toast) {
		@apply fixed bottom-2 right-2;
	}

</style>

{#if import.meta.env.VITE_HOSTNAME === "localhost" || $user?.npub === "npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft"}
	<button
		on:click={() => $debugMode = !$debugMode}
		class="max-sm:hidden fixed bottom-2 right-2 z-50 btn btn-circle btn-sm">
		<Bug size="24" class={$debugMode ? "text-accent2" : "text-neutral-500"} />
	</button>
{/if}