<script lang="ts">
    import { login } from '$lib/utils/login';
    import { browser } from '$app/environment';
	import { ndk, user } from '@kind0/ui-common';

    let noNip07extenion: boolean;

    $: noNip07extenion = browser ? !window.nostr : false;
    const hostname = $page.url.hostname;

    async function loginNip07() {
        const u = await login($ndk, undefined, 'nip07', hostname);

        if (!u) {
            alert('Login failed');
        } else {
            alert('changing user')
            $user = u;
            localStorage.setItem('nostr-key-method', 'nip07');
            localStorage.setItem('nostr-target-npub', $user.npub);
        }
    }
</script>

{#if noNip07extenion}
    <div class="alert flex flex-col bg-base-300">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-info shrink-0 w-6 h-6"
            ><path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            /></svg
        >
        <span>No Nostr extension in your browser</span>
        <div class="hidden">
            <button class="btn btn-xs">Need help?</button>
        </div>
    </div>
{:else}
    <button on:click={loginNip07} class="w-full">
        <span>Use Browser Extension</span>
    </button>
{/if}
