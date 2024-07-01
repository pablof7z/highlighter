<script lang="ts">
    import { userProfile as currentUserProfile } from "$stores/session";
    import { profileFromEvent, type Hexpubkey, type NDKEvent, type NDKSubscriptionOptions, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
    import currentUser from "$stores/currentUser";
    import type { NDKRelay, NDKSubscription, NDKUser } from "@nostr-dev-kit/ndk";
    import type { UserProfileType } from "../../../app";
	import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";
    import { createEventDispatcher, onDestroy } from "svelte";
    import createDebug from "debug";
    import { refresh } from "$utils/profile-refresh.js";
    import { inview } from 'svelte-inview';
	import { vanityUrls } from "$utils/const";
	import { isMobileBuild } from "$utils/view/mobile";
	import { ndk } from "$stores/ndk";

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
        if (isMobileBuild() && user) {
            authorUrl = `/mobile/profile?userId=${user.npub}`
        } else {
            authorUrl = `/${user?.npub}`;
        }
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
        let profileCreatedAt: number;
        $ndk.cacheAdapter?.fetchProfile(user.pubkey).then((p) => {
            if (p) {
                userProfile ??= p;
                profileCreatedAt = p.created_at;

                // not sure why this hack is needed
                setTimeout(() => {
                    userProfile ??= p;
                }, 100);
            }

            // push a profile refresh to be grouped
            refresh(user.pubkey, p, (newProfile: NDKUserProfile, newEvent: NDKEvent) => {
                d(`refreshed profile`, newProfile);
                userProfile = newProfile;
                event = newEvent;
                dispatch("newProfileAfterEose", userProfile);
            });
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
            { groupableDelayType: 'at-most', subId, groupable, closeOnEose, cacheUsage, ...subsOptions},
            undefined, false
        );
        // console.log('fetching profile', user?.pubkey, subscription)

        if (subscription) {
            subscription.on("event", (e: NDKEvent, r: NDKRelay) => {
                // console.log('event profile', user?.pubkey, e.rawEvent())
                
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

    let userHasVanityUrl = false;

    // if there is a user, see if we find the user's pubkey in a value, if we find it the key is the authorUrl with / prefix
    if (user && !isMobileBuild()) {
        for (const key in vanityUrls) {
            if (vanityUrls[key] === user.pubkey) {
                userHasVanityUrl = true;
                authorUrl = `/${key}`;
                break;
            }
        }
    }

    $: if (userProfile && fetching) fetching = false;
    $: if (userProfile && userProfile.nip05 && !fetching) displayNip05 = prettifyNip05(userProfile.nip05, 999999)
    $: if (userProfile && user && userProfile.nip05 && validatedNip05 === undefined && !userHasVanityUrl) {
        user.ndk = $ndk;
        if (!isMobileBuild()) {
            user.validateNip05(userProfile.nip05).then((v) => {
                validatedNip05 = true;
                if (v) authorUrl = `/${displayNip05}`;
            }).catch((e) => {
                console.error(e);
            });
        }
    }

    // $: console.log('update', userProfile?.displayName)
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