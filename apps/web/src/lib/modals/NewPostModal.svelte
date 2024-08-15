<script lang="ts">
	import ModalShell from "$components/ModalShell.svelte";
	import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
    import * as Composer from "$components/Composer";
	import { closeModal } from "$utils/modal";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { replyKind } from "$utils/event";
	import { State as AudienceState } from "$components/Audience";
	import { Writable } from "svelte/store";

    export let audience: AudienceState | undefined = undefined;
    
    export let replyTo: NDKEvent | undefined = undefined;
    export let kind: NDKKind | undefined = undefined;
    export let onPublish: ((event: NDKEvent) => void) | undefined = undefined;

    export let state: Writable<Composer.State> | undefined = undefined;

    if (replyTo) kind ??= replyKind(replyTo);

    let title: string | undefined;
</script>

<Composer.Root
    {replyTo}
    {kind}
    {audience}
    bind:state
    let:actionButtons
    let:secondaryButtons
    on:publish={(e) => {
        onPublish?.(e);
        closeModal();
    }}
>
    <ModalShell {title}
        {secondaryButtons}
        {actionButtons}
        class="max-sm:h-[90dvh]"
    >
        {#if replyTo}
            <EventWrapper
                event={replyTo}
                compact
                skipFooter
                class="bg-secondary rounded max-h-[15dvh] overflow-y-auto"
            />
        {/if}
        <Composer.Editor {state} />
        <Composer.Attachments {state} />
    </ModalShell>
</Composer.Root>