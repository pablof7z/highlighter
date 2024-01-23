<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { login } from "$utils/login";
	import { bunkerNDK, ndk } from "@kind0/ui-common";
	import { onMount } from "svelte";

    // get pubkey from url param
    const pubkey = $page.url.searchParams.get('pubkey');

    let logging = true;

    onMount(async () => {
        if (!pubkey) return goto('/');

        const user = $ndk.getUser({pubkey});
        localStorage.setItem('nostr-target-npub', user.npub);
        localStorage.setItem("nostr-key-method", 'nip46');

        if (!await login($ndk, $bunkerNDK, 'nip46')) {
            logging = false;
        } else {
            const intendedUrl = localStorage.getItem('intended-url') || '/';
            goto(intendedUrl);
        }
    });

</script>

<LoadingScreen ready={!logging}>
    Unable to finish login.
</LoadingScreen>