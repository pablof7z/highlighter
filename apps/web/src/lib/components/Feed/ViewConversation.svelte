<script lang="ts">
    import { debugMode } from "$stores/session";
    import { Name, ndk } from "@kind0/ui-common";
    import { NDKEvent, getRootEventId } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let urlPrefix: string = "/e/";

    let rootEvent: NDKEvent | undefined | null | "not-fetched" = "not-fetched";
    let replyToEvent: NDKEvent | undefined | null | "not-fetched" = "not-fetched";

    event.fetchRootEvent().then((e: NDKEvent | null) => rootEvent = e);
    event.fetchTaggedEvent("e", "reply").then((e: NDKEvent | null) => replyToEvent = e);
</script>

<div class="flex flex-row gap-4 truncate ">
    {#if replyToEvent instanceof NDKEvent}
        <a href="{urlPrefix}{replyToEvent.encode()}">
            replying to
            <Name user={replyToEvent.author} />
        </a>
    {/if}

    {#if rootEvent instanceof NDKEvent}
        {#if replyToEvent === undefined}
            <a href="{urlPrefix}{rootEvent.encode()}">
                replying to
                <Name user={rootEvent.author} />
            </a>
        {:else if replyToEvent?.id !== rootEvent.id}
            <a href="{urlPrefix}{rootEvent.encode()}">
                View
                conversation
            </a>
        {/if}
    {/if}
</div>

{#if $debugMode}
    <div>
        {JSON.stringify(event.tags)}
    </div>
{/if}

<style lang="postcss">
    a {
        @apply text-sm text-white underline;
    }
</style>