<script lang="ts">
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import AvatarWithName from "../user/AvatarWithName.svelte";
    import * as Card from "@components/ui/card";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
    import { ndk } from "@/state/ndk";
	import RelativeTime from "../RelativeTime.svelte";
    import { readingTime } from "@highlighter/common";

    let { event } = $props();
</script>

{#if event instanceof NDKArticle}
    <Card.Root>
        <Card.Content class="flex flex-row p-0 w-full">
            <div class="flex-none w-32 h-32 rounded-l-lg overflow-hidden bg-muted">
                {#if event.image}
                    <img src={event.image} alt={event.title} class="w-full h-full object-cover" />
                {/if}
            </div>
            <div class="flex flex-col gap-0 p-2 px-4 w-[calc(100%-128px)]">
                <div class="flex flex-col gap-1 grow">
                    <h4 class="text-base font-semibold text-foreground overflow-clip truncate">{event.title}</h4>
                    <div class="text-[12px] leading-[20px] max-h-[40px] overflow-clip text-muted-foreground">{event.summary}</div>
                </div>

                <div class="flex flex-row justify-between items-center">
                    <AvatarWithName of={event.pubkey} avatarSize="small" nameClass="text-muted-foreground text-xs" />
                    
                    <span class="text-xs text-muted-foreground">
                        {readingTime(event.content)}m read
                    </span>
                </div>
            </div>
        </Card.Content>
    </Card.Root>
{:else if event.kind === 1}
    <Card.Root class="col-span-2">
        <Card.Header class="flex flex-row items-center justify-between">
            <AvatarWithName of={event.pubkey} avatarSize="small" nameClass="text-muted-foreground text-xs" />
            <RelativeTime {event} class="text-muted-foreground text-xs" />
        </Card.Header>
        <Card.Content>
            <EventContent {ndk} {event} />
        </Card.Content>
    </Card.Root>
{:else}
    {@const alt = event.alt}
    <Card.Root class="col-span-2">
        <Card.Header class="flex flex-row items-center justify-between">
            <AvatarWithName of={event.pubkey} avatarSize="small" nameClass="text-muted-foreground text-xs" />
            <RelativeTime {event} class="text-muted-foreground text-xs" />
        </Card.Header>
        <Card.Content>
            {alt}
            <div class="!text-xs">
                <EventContent {ndk} {event} class="!text-xs" />

            </div>
        </Card.Content>
        <Card.Footer>
            <div class="flex flex-row items-center justify-between text-xs text-muted-foreground">
                Event type: {event.kind}
            </div>
        </Card.Footer>
    </Card.Root>
{/if}