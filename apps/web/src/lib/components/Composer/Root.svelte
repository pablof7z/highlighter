<script lang="ts">
	import { Writable, writable } from "svelte/store";
	import { Actions, State } from ".";
	import publish from "./actions/publish.js";
	import { NDKEvent, NDKKind, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
	import upload from "./actions/upload";
	import { Gif, Image, Timer } from "phosphor-svelte";
	import { createEventDispatcher, setContext } from "svelte";
	import * as Audience from "$components/Audience";
	import { NavigationOption } from "../../../app";
	import saveDraft from "./actions/save-draft.js";
    import * as Draft from "$components/Draft";

    export let audience: Audience.State = { scope: 'public' };

    export let replyTo: NDKEvent | undefined = undefined;
    export let mentionEvent: NDKEvent | undefined = undefined;
    export let kind: NDKKind | undefined = undefined;
    export let tags: NDKTag[] = [];
    let secondaryButtons: NavigationOption[] | undefined = undefined;

    /**
     * RelaySet where to publish the event
     */
    export let relaySet: NDKRelaySet | undefined = undefined;
    
    export let state = writable<State>({
        kind,
        tags,
        replyTo,
        mentionEvent,
        audience,
        dispatch: createEventDispatcher(),
    });

    $state.audience.scope ??= 'public';

    let canPublish = true;

    $: {
        canPublish = true;
        
        // if set to private, require at least one group
        if ($state.audience.scope === 'private' &&
            (!$state.audience.groups || $state.audience.groups.length === 0)
        ) {
            canPublish = false;
        }

        // make sure we have some content
        if ((!$state.content || $state.content.trim().length === 0) && !$state.attachments?.length) {
            canPublish = false;
        }
    }

    export let actions: Actions = {
        publish: publish.bind(null, state),
        upload: upload.bind(null, state),
        saveDraft: saveDraft.bind(null, state),
        schedule: () => {},
    }

    let actionButtons: NavigationOption[];

    const audienceStore = writable<Audience.State>(audience);
    $: $state.audience = $audienceStore;
    
    $: actionButtons = [
        { id: "Schedule", icon: Timer, fn: actions.schedule, buttonProps: { class: 'rounded-full', variant: "secondary", size: 'icon' } },
        { name: "Publish", fn: actions.publish, buttonProps: { class: 'px-6', variant: 'default', disabled: !canPublish } }
    ]
    
    $: {
        secondaryButtons = [
            { id: 'image', icon: Image, fn: actions.upload, buttonProps: { class: 'rounded-full', variant: 'ghost', size: 'icon' } },
            { id: 'draft', component: { component: Draft.Button, props: { save: actions.saveDraft, label: false } } },
            // { id: 'gif', icon: Gif, fn: actions.upload, buttonProps: { class: 'rounded-full', variant: 'ghost', size: 'icon' } },
        ]

        if (!replyTo) {
            secondaryButtons.unshift({ id: 'audience', component: { component: Audience.Button, props: { state: audienceStore } } })
        }
    }
</script>

{#if state}
    <slot
        {state}
        {actions}
        {actionButtons}
        {secondaryButtons}
    />
{/if}