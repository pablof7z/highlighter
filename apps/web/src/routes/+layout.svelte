<script lang="ts">
	import { initJobRequests, userJobRequests } from '$stores/jobRequests';
	import ndk from '$stores/ndk';
	import { onMount } from 'svelte';
	import '../app.postcss';
	import { NDKNip07Signer } from '@nostr-dev-kit/ndk';
	import { currentUser } from '$stores/current-user';
	import Navbar from '$components/Navbar.svelte';
	import { Modals, closeModal } from 'svelte-modals'
	import { fade } from 'svelte/transition';
	import { initNotifications } from '$stores/notifications';

	onMount(async () => {
        try {
            $ndk.connect();

			if (localStorage.getItem('nostr-key-method') === 'nip07') {
				await login();
			}
        } catch (e) {
            console.error(`layout error`, e);
        }
    });

	async function login() {
		$ndk.signer = new NDKNip07Signer();
		$currentUser = await $ndk.signer?.blockUntilReady();
		$currentUser.ndk = $ndk;

		if ($currentUser) {
			localStorage.setItem('nostr-key-method', 'nip07');
		}
	}

	$: if ($currentUser && !$userJobRequests) {
		console.log(`init`);
		initJobRequests();
		initNotifications();
	}
</script>

<Navbar />

<Modals>
    <div
        slot="backdrop"
        class="backdrop z-20 fixed"
        on:click={closeModal}
        transition:fade={{ duration: 100 }}></div>
</Modals>

<div class="mx-auto">
	<slot />
</div>

<style lang="postcss">
	:global(.userCard .userCard--avatar .avatar--image) {
		@apply w-12 h-12;
	}

	.backdrop {
        position: fixed;
        top: 0;
        bottom: 0;
        right: 0;
		backdrop-filter: blur(0.15rem);
        left: 0;
        background: rgba(0,0,0,0.50)
    }
</style>
