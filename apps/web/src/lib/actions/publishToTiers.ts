import type NDK from "@nostr-dev-kit/ndk";
import { NDKEvent, NDKRelaySet, NDKUser } from "@nostr-dev-kit/ndk";

const defaultRelays = [
    'wss://relay.getfaaans.com'
    // "ws://localhost:5577"
];

export async function publishToTiers(
    event: NDKEvent,
    tiers: Record<string, boolean>,
    opts: {
        teaserEvent?: NDKEvent,
        ndk?: NDK,
        relaySet?: NDKRelaySet,
    } = {}
) {
    const ndk = opts.ndk ?? event.ndk!;
    opts.relaySet ??= NDKRelaySet.fromRelayUrls(defaultRelays, ndk);

    const user: NDKUser = await ndk.signer!.user();

    if (!event.tagValue("h")) {
        // Add NIP-29 group `h` tag
        event.tags.push(
            ["h", user.pubkey ]
        )
    }

    // Annotate the `d` tags with the tier
    for (const tier in tiers) {
        if (!tiers[tier]) continue;

        event.tags.push(
            ["d", tier]
        )
    }

    await event.publish(opts.relaySet);

    console.log(event.rawEvent());
}

// async function publish() {
//     let previewArticle: NDKArticle | undefined;

//     // Don't create a preview article if all tiers are selected
//     if (Object.keys(tiers).filter(tier => tiers[tier]).length === Object.values(tiers).length) {
//         nonSubscribersPreview = false;
//     }

//     // Create a preview article if necessary
//     const tierEvents = Array.from(await $ndk.fetchEvents(
//         {kinds: [NDKKind.CurationSet], authors: [$user.pubkey]},
//         {},
//         relaySet
//     ))

//     // Go through the tiers and publish the article to each one
//     for (const tier in tiers) {
//         if (!previewArticle && !tiers[tier]) continue;

//         let tierEvent;// = tierEvents.find((event: NDKEvent) => event.tagValue("d") === tier);
//         let tierList: NDKList;
//         if (tierEvent) {
//             tierList = NDKList.from(tierEvent);
//         } else {
//             tierList = new NDKList($ndk, {
//                 kind: NDKKind.CurationSet,
//                 tags: [ [ "d", tier ] ],
//             } as NostrEvent);
//             tierList.title = title;
//         }

//         const articleToAdd = tiers[tier] ? article : previewArticle;

//         tierList.tags.unshift(articleToAdd?.tagReference()!);
//         await tierList.publish(relaySet);
//     }
// }