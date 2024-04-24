<script lang="ts">
    import { ndk, user as currentUser } from "@kind0/ui-common";
    import { userProfile as currentUserProfile } from "$stores/session";
    import { profileFromEvent, type Hexpubkey, type NDKEvent, type NDKSubscriptionOptions, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
    import type { NDKRelay, NDKSubscription, NDKUser } from "@nostr-dev-kit/ndk";
    import type { UserProfileType } from "../../../app";
	import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";
    import { createEventDispatcher, onDestroy, tick } from "svelte";
    import createDebug from "debug";
    import { inview } from 'svelte-inview';

    export let pubkey: Hexpubkey | undefined = undefined;
    export let npub: string | undefined = undefined;
    export let user: NDKUser | undefined = undefined;
    export let subsOptions: NDKSubscriptionOptions | undefined = undefined;
    export let displayNip05: string | undefined = undefined;
    export let forceFetch: boolean = false;
    export let event: NDKEvent | undefined = undefined;
    export let allowLazyLoading = true;

    const d = createDebug("HL:UserProfile");
    const dispatch = createEventDispatcher();

    if (!user && (npub || pubkey)) {
        user ??= $ndk.getUser({npub, pubkey});
    }

    export let authorUrl: string | undefined = undefined;

    try {
        authorUrl = `/${user?.npub}`;
    } catch {
        authorUrl = "";
        user = undefined;
    }

    export let userProfile: UserProfileType | undefined | null = undefined;
    export let fetching: boolean = !userProfile;

    let sameUser: boolean = user?.pubkey === $currentUser?.pubkey;
    let checkedCache = false;

    if (sameUser) {
        user = $currentUser;
    }

    $: if (sameUser) {
        if ($currentUserProfile) {
            userProfile = {...$currentUserProfile};
            fetching = false;
        }
    }

    let kind0Event: NDKEvent | undefined = undefined;

    if ($ndk.cacheAdapter?.fetchProfile && user?.pubkey && !checkedCache) {
        checkedCache = true
        $ndk.cacheAdapter?.fetchProfile(user.pubkey).then((p) => {
            if (p) {
                userProfile ??= p;

                // not sure why this hack is needed
                setTimeout(() => {userProfile ??= p;}, 100);
            }
        }).catch((e: any) => {
            console.error(e);
        });
    } else {
        d(`Not hitting cache code`, {
            fetchProfile: !!$ndk.cacheAdapter?.fetchProfile,
            pubkey: !!user?.pubkey,
            fetching: !!fetching
        })
    }

    const closeOnEose = user?.pubkey !== $currentUser?.pubkey;
    const cacheUsage = forceFetch ? NDKSubscriptionCacheUsage.ONLY_RELAY : NDKSubscriptionCacheUsage.CACHE_FIRST;
    const groupable = !forceFetch;

    let subscription: NDKSubscription | undefined = undefined;

    function fetchProfileRemotely() {
        fetching = true;
        const subId = subsOptions?.subId ?? 'user-profile';
        subscription = fetching && user && $ndk.subscribe(
            [ { kinds: [0], authors: [user.pubkey] }, ],
            { groupableDelayType: 'at-least', subId, groupable, closeOnEose, cacheUsage, ...subsOptions},
            undefined, false
        );

        if (subscription) {
            subscription.on("event", (e: NDKEvent, r: NDKRelay) => {
                const noKind0Event = !kind0Event;
                const kind0EventIsOlder = kind0Event?.created_at! < e.created_at!;

                if ((noKind0Event || kind0EventIsOlder)) {
                    kind0Event = e;
                    userProfile = profileFromEvent(e) as UserProfileType;
                    event = e;

                    if (!fetching) {
                        dispatch("newProfileAfterEose", userProfile);
                    }
                }
            });
            subscription.on("eose", () => { fetching = false; });
            subscription.start();
        }
    }

    onDestroy(() => {
        if (subscription) subscription.stop();
    })

    // If we are not lazy loading and we don't have the userprofile, fetch it
    if (!allowLazyLoading && !fetching && !userProfile) {
        fetchProfileRemotely();
    }

    let validatedNip05: boolean | undefined;

    $: if (userProfile && fetching) fetching = false;
    $: if (userProfile && userProfile.nip05 && !fetching) displayNip05 = prettifyNip05(userProfile.nip05, 999999)
    $: if (userProfile && user && userProfile.nip05 && validatedNip05 === undefined) {
        user.ndk = $ndk;
        user.validateNip05(userProfile.nip05).then((v) => {
            validatedNip05 = true;
            if (v) authorUrl = `/${displayNip05}`;
        }).catch((e) => {
            console.error(e);
        });
    }
</script>


<slot {userProfile} {fetching} {authorUrl} {displayNip05} {event} />

{#if allowLazyLoading}
    {#if !userProfile}
        <div use:inview={{
            rootMargin: '50px',
            unobserveOnEnter: true,
            threshold: 0.5
        }}
            on:inview_enter={fetchProfileRemotely}
        />
    {/if}
{/if}