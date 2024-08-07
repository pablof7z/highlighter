<script lang="ts">
	import { Writable, writable } from "svelte/store";
	import { ComposerState } from ".";
	import publish from "./actions/publish.js";
	import { NDKEvent, NDKKind, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
	import upload from "./actions/upload";
	import { Gif, Image, Timer } from "phosphor-svelte";
	import { createEventDispatcher, setContext } from "svelte";

    export let replyTo: NDKEvent | undefined = undefined;
    export let mentionEvent: NDKEvent | undefined = undefined;
    export let kind: NDKKind | undefined = NDKKind.Text;
    export let tags: NDKTag[] = [];

    /**
     * RelaySet where to publish the event
     */
    export let relaySet: NDKRelaySet | undefined = undefined;
    
    export let state: Writable<ComposerState> | undefined = undefined;
    state = writable<ComposerState>({
        kind,
        tags,
        replyTo,
        relaySet,
        mentionEvent,
        dispatch: createEventDispatcher(),
    });

    const actions = {
        publish: publish.bind(null, state),
        upload: upload.bind(null, state),
        schedule: () => {},
    }

    const actionButtons = [
        { id: "Schedule", icon: Timer, fn: actions.schedule, buttonProps: { class: 'rounded-full', size: 'icon' } },
        { name: "Publish", fn: actions.publish, buttonProps: { class: 'px-6', variant: 'default' } }
    ]

    const secondaryButtons=[
        // { name: 'Drafts', fn: actions.upload, buttonProps: { variant: 'link' } },
        { id: 'image', icon: Image, fn: actions.upload, buttonProps: { class: 'rounded-full', variant: 'ghost', size: 'icon' } },
        // { id: 'gif', icon: Gif, fn: actions.upload, buttonProps: { class: 'rounded-full', variant: 'ghost', size: 'icon' } },
    ]
</script>

{#if state}
    <slot
        {state}
        {actions}
        {actionButtons}
        {secondaryButtons}
    />
{/if}