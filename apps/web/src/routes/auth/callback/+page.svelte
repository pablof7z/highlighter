<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { userPubkey } from "$stores/currentUser";
	import { login } from "$utils/login";
	import { ndk } from "$stores/ndk.js";
	import { onMount } from "svelte";

    // get pubkey from url param
    const pubkey = $page.url.searchParams.get('pubkey');

    let logging = true;

    onMount(async () => {
        if (!pubkey) return goto('/');

        const user = $ndk.getUser({pubkey});
        loginMethod.set('nip46');
        userPubkey.set(user.pubkey);

        if (!await login('nip46', pubkey)) {
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