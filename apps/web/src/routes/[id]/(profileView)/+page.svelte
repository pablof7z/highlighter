<script lang="ts">
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk.js";
	import * as User from "$components/User";
	import { NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let userProfile: NDKUserProfile;

    let id: string;
    let { user } = $page.data;

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        user.ndk = $ndk;
    }
</script>

{#if user}
    <User.HomePage {userProfile} />
{/if}