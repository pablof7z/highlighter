<script lang="ts">
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let userProfile: NDKUserProfile | undefined;
</script>

<div class="flex flex-row justify-between items-center">
    <AvatarWithName user={event.author} {userProfile} avatarSize="tiny" nameClass="text-muted-foreground text-xs" />

    <RelativeTime {event} class="opacity-50" />
</div>