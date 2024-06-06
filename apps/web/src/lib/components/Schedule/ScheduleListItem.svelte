<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Repeat } from "phosphor-svelte";

    export let scheduleEvent: NDKEvent;
    export let event: NDKEvent;

    const events = $ndk.storeSubscribe(
        scheduleEvent.filter(),
        { groupable: true, groupableDelay: 500, groupableDelayType: 'at-least' }
    );
    const pTag = scheduleEvent.tagValue('p');
    const dvmUser = $ndk.getUser({pubkey: pTag});

    let repostEvent: NDKEvent;

    if (event.kind === 6) {
        repostEvent = event;
        event = new NDKEvent($ndk, JSON.parse(event.content));
    }
</script>

{#if repostEvent}
<div class="text-foreground">
    <Repeat size={20} class="text-accent inline" />
    Repost 
    <RelativeTime timestamp={repostEvent.created_at*1000} />
</div>
{/if}

<EventWrapper
    {event}
    skipFooter={true}
    skipReply={true}
    showReply={false}
/>

<div class="text-xs font-white flex flex-row items-center gap-2">
    Scheduling provided by
    <AvatarWithName user={dvmUser} avatarType="circle" avatarSize="small" class="text-foreground" />
</div>