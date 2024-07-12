<script lang="ts">
	import EventPublishedTarget from "$components/Event/EventPublishedTarget.svelte";
	import BackButton from "$components/App/Navigation/BackButton.svelte";
	import RelativeTime from "$components/PageElements/RelativeTime.svelte";
	import Avatar from "$components/User/Avatar.svelte";
	import Name from "$components/User/Name.svelte";
    import { NDKEvent, NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let userProfile: NDKUserProfile;
    export let authorUrl: string;
    const pubkey = event.pubkey;
</script>

<div class="flex flex-row w-full gap-2 {$$props.class??""}">
    <div class="flex flex-row items-center">
        <BackButton />
    </div>
    
    <a href={authorUrl}>
        <Avatar {pubkey} {userProfile} size="medium" />
    </a>

    <div class="flex flex-col items-start grow ml-2">
        <a href={authorUrl}>
            <Name {pubkey} {userProfile} {authorUrl} class="text-foreground font-medium" />
        </a>
        <EventPublishedTarget {event} />
    </div>

    <div class="text-right text-xs text-muted-foreground">
        <RelativeTime {event} />
    </div>
</div>