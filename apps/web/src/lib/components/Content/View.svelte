<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;

    const author = event.author;
    let userProfile: NDKUserProfile;
</script>

<UserProfile {author} bind:userProfile />