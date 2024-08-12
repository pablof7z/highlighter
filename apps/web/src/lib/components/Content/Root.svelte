<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKSubscriptionOptions, NDKUser, filterAndRelaySetFromBech32 } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { onDestroy, onMount } from "svelte";
	import { WrappedEvent } from "../../../app";
	import { mainContentKinds, wrapEvent } from "$utils/event";

    /**
     * This component makes an event available based on some information,
     * like the user + dTag, a bech32 encoded event.
    */
    export let user: NDKUser | undefined = undefined;
    export let dTag: string | undefined = undefined;

    export let bech32: string | undefined = undefined;

    /**
     * This is for passthrough loading of events, or when we already have the event.
     * This will turn this component into a noop.
     */
    export let event: NDKEvent | undefined = undefined;
    export let wrappedEvent: WrappedEvent | undefined = undefined;

    export let subOpts: NDKSubscriptionOptions = {
        groupable: false,
        subId: 'content-root-fetcher'
    }

    // Do we have enough information to proceed?
    let validInformation: boolean;

    let loading: boolean | undefined;
    let eosed = false;

    $: if (!sub) {
        if (user && dTag) {
            validInformation = true;
            loadViaUser();
        } else if (bech32) {
            validInformation = true;
            loadViaBech32();
        } else if (event) {
            validInformation = true;
            wrappedEvent = wrapEvent(event);
        } else {
            validInformation = false;
        }
    }

    let sub: NDKEventStore<NDKEvent> | undefined;

    function startLoadingTimer() { setTimeout(() => { loading = true; }, 1000); }

    function onEose() { eosed = true; }

    function onEvent(e: NDKEvent) {
        if (!event || event.created_at! <= e.created_at!) {
            event = e;
            wrappedEvent = wrapEvent(e);
        }
    }

    function loadViaBech32() {
        if (!bech32) return;
        const { filter, relaySet } = filterAndRelaySetFromBech32(bech32, $ndk);
        console.log({filter, relays: relaySet?.relayUrls, bech32})
        sub = $ndk.storeSubscribe(filter, {
            ...subOpts,
            relaySet,
            onEose: () => {
                // check if we have been able to fetch from this relay (if a relayset was provided)
                // if we eosed, there was a relayset and we didn't load anything, run without relayset
                if (!event && relaySet) {
                    sub?.unsubscribe();
                    sub = $ndk.storeSubscribe(filter, {
                        ...subOpts, onEose, onEvent
                    });
                } else {
                    eosed = true;
                }
            },
            onEvent
        });
    }

    function loadViaUser() {
        console.log('loading via user');
        if (!user || !dTag) return;
        startLoadingTimer();
        sub = $ndk.storeSubscribe({ authors: [user.pubkey], "#d": [dTag], kinds: mainContentKinds }, {
            ...subOpts, onEose, onEvent
        });
    }

    let e: NDKEvent | undefined;


    $: if (sub && $sub && $sub.length > 0 && event?.id !== $sub[0].id) {
        event = $sub[0];
        wrappedEvent = wrapEvent(event);
    }

    onMount(() => {
        console.log('mounting content root!');
    });

    onDestroy(() => {
        console.log('destroying content root');
        sub?.unsubscribe();
    });
</script>

{#if !validInformation}
    <p>We encountered an error; we didn't receive enough information of what you want to load!</p>
{:else if event}
    <slot {event} {wrappedEvent} />
{:else if loading}
    Loading
{/if}