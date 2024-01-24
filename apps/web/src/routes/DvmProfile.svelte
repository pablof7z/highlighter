<script lang="ts">
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
import { ndk } from "@kind0/ui-common";
	import type { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import type { UserProfileType } from "../app";

    export let dvm: NDKEvent;

    let profile: UserProfileType | null;

    try {
        profile = JSON.parse(dvm.content);
    } catch {
        dvm.author.fetchProfile().then(u => profile = u);
    }
</script>

{#if profile}
    <li>
        <AvatarWithName user={dvm.author} userProfile={profile} />
    </li>
{/if}