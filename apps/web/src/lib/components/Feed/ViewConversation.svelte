<script lang="ts">
    import { debugMode } from "$stores/session";
    import { Name, ndk } from "@kind0/ui-common";
    import { NDKEvent, getRootEventId } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let urlPrefix: string = "/e/";
    export let isNoop: boolean | undefined = false;

    let rootEvent: NDKEvent | undefined | null | "not-fetched" = "not-fetched";
    let replyToEvent: NDKEvent | undefined | null | "not-fetched" = "not-fetched";

    event.fetchRootEvent().then((e: NDKEvent | null) => rootEvent = e);
    event.fetchTaggedEvent("e", "reply").then((e: NDKEvent | null) => replyToEvent = e);

    $: isNoop = !(replyToEvent instanceof NDKEvent || rootEvent instanceof NDKEvent);
</script>

<div class="flex flex-row gap-4 truncate ">
    {#if replyToEvent instanceof NDKEvent}
        <a href="{urlPrefix}{replyToEvent.encode()}">
            reply to
            @<Name user={replyToEvent.author} attribute="name" />
        </a>
    {/if}

    {#if rootEvent instanceof NDKEvent}
        {#if replyToEvent === undefined}
            <a href="{urlPrefix}{rootEvent.encode()}">
                reply to
                @<Name user={rootEvent.author} attribute="name" />
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