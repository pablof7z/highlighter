<script lang="ts">
    import { ndk, user as currentUser } from "@kind0/ui-common";
    import { userProfile as currentUserProfile } from "$stores/session";
    import { profileFromEvent, type Hexpubkey, type NDKEvent, type NDKSubscriptionOptions, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
    import type { NDKRelay, NDKUser } from "@nostr-dev-kit/ndk";
    import type { UserProfileType } from "../../../app";
	import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";
    import { createEventDispatcher, onDestroy } from "svelte";

    export let pubkey: Hexpubkey | undefined = undefined;
    export let npub: string | undefined = undefined;
    export let user: NDKUser | undefined = undefined;
    export let subsOptions: NDKSubscriptionOptions | undefined = undefined;
    export let displayNip05: string | undefined = undefined;
    export let forceFetch: boolean = false;

    const dispatch = createEventDispatcher();

    if (!user && (npub || pubkey)) {
        user ??= $ndk.getUser({npub, pubkey});
    }

    export let authorUrl: string = `/${user?.npub}`;
    export let userProfile: UserProfileType | undefined | null = undefined;
    export let fetching: boolean = !userProfile;

    let sameUser: boolean = user?.pubkey === $currentUser?.pubkey;

    if (sameUser) {
        user = $currentUser;
    }

    $: if (sameUser) {
        if ($currentUserProfile) {
            console.log("getting from currentUserProfile", $currentUserProfile);
            userProfile = {...$currentUserProfile};
            fetching = false;
        } else {
            console.log("fetching from currentUser", $currentUser);
            fetching = true;
        }
    }

    let kind0Event: NDKEvent | undefined = undefined;

    // if ($ndk.cacheAdapter?.fetchProfile) {
    //     $ndk.cacheAdapter?.fetchProfile(user.pubkey).then((p) => {
    //         userProfile ??= p;
    //     }).catch((e: any) => {
    //         console.error(e);
    //     });
    // }

    const closeOnEose = user?.pubkey !== $currentUser?.pubkey;
    const cacheUsage = forceFetch ? NDKSubscriptionCacheUsage.ONLY_RELAY : NDKSubscriptionCacheUsage.PARALLEL;
    const groupable = !forceFetch;

    const sub = fetching && user && $ndk.subscribe([
        { kinds: [0], authors: [user.pubkey] },
    ], { groupable, closeOnEose, cacheUsage, ...subsOptions});

    onDestroy(() => {
        if (sub) sub.stop();
    })

    if (sub) {
        sub.on("event", (e: NDKEvent, r: NDKRelay) => {
            const noKind0Event = !kind0Event;
            const kind0EventIsOlder = kind0Event?.created_at! < e.created_at!;

            if ((noKind0Event || kind0EventIsOlder)) {
                kind0Event = e;
                userProfile = profileFromEvent(e) as UserProfileType;

                if (!fetching) {
                    dispatch("newProfileAfterEose", userProfile);
                }
            }
        });
        sub.on("eose", () => { fetching = false; });
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

<slot {userProfile} {fetching} {authorUrl} {displayNip05} />