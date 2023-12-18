<script lang="ts">
    import { ndk } from "@kind0/ui-common";
    import { profileFromEvent, type Hexpubkey, type NDKEvent, type NDKSubscriptionOptions, type NDKUserProfile, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
    import type { NDKRelay, NDKUser } from "@nostr-dev-kit/ndk";
    import type { UserProfileType } from "../../../app";
	import { prettifyNip05 } from "@nostr-dev-kit/ndk-svelte-components";

    export let pubkey: Hexpubkey | undefined = undefined;
    export let npub: string | undefined = undefined;
    export let user: NDKUser | undefined = $ndk.getUser({npub, pubkey});
    export let subsOptions: NDKSubscriptionOptions | undefined = undefined;
    export let displayNip05: string | undefined = undefined;

    user ??= $ndk.getUser({npub, pubkey});

    export let authorUrl: string = `/${user.npub}`;

    let fetching: boolean = true;

    export let userProfile: UserProfileType | undefined | null = undefined;
    let error: string | undefined = undefined;

    let kind0Event: NDKEvent | undefined = undefined;
    export let kind37777Event: NDKEvent | undefined = undefined;

    if ($ndk.cacheAdapter?.fetchProfile) {
        $ndk.cacheAdapter?.fetchProfile(user.pubkey).then((p) => {
            userProfile ??= p;
        }).catch((e: any) => {
            console.error(e);
        });
    }

    const sub = $ndk.subscribe([
        { kinds: [0, 37777], authors: [user.pubkey] },
    ], { closeOnEose: true, cacheUsage: NDKSubscriptionCacheUsage.PARALLEL, ...subsOptions});

    sub.on("event", (e: NDKEvent, r: NDKRelay) => {
        switch (e.kind) {
            case 0: {
                const no31777Received = !kind37777Event;
                const noKind0Event = !kind0Event;
                const kind0EventIsOlder = kind0Event?.created_at! < e.created_at!;

                if (no31777Received && (noKind0Event || kind0EventIsOlder)) {
                    kind0Event = e;
                    userProfile = profileFromEvent(e);
                    console.log(`getting from`, r?.url, e.rawEvent())
                }
                break;
            }
            case 37777: {
                if (!kind37777Event || kind37777Event.created_at! < e.created_at!) {
                    kind37777Event = e;
                    userProfile = profileFromEvent(e);
                    userProfile.categories = e.getMatchingTags("t").map(t => t[1]) || [];
                    userProfile = userProfile;
                    console.log(`categories`, userProfile.categories);
                }
            }
        }
    });
    sub.on("eose", () => { fetching = false; });

    $: if (userProfile && fetching) fetching = false;
    $: if (userProfile && userProfile.nip05) displayNip05 = prettifyNip05(userProfile.nip05, 999999)
    $: if (userProfile && user) authorUrl = `/${displayNip05||user.npub}`;
</script>

<slot {userProfile} {fetching} {authorUrl} {displayNip05} />