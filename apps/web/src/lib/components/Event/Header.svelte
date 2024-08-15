<script lang="ts">
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let nameClass = "text-muted-foreground text-xs";
    export let avatarSize = "tiny";
</script>

<div class="flex flex-row justify-between items-center">
    <AvatarWithName user={event.author} {userProfile} {avatarSize} {nameClass} />

    <RelativeTime {event} class="opacity-50" />
</div>