<!-- <script lang="ts">
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk.js";
	import UserProfileHomePage from "$views/UserProfileHomePage.svelte";

    let id: string;
    let { user } = $page.data;

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        user.ndk = $ndk;
    }
</script>

{#if user}
    <UserProfileHomePage {user} />
{/if} -->