import type NDK from "@nostr-dev-kit/ndk";
import type { NDKEvent, NDKRelaySet, NDKUser } from "@nostr-dev-kit/ndk";
import { getDefaultRelaySet } from "$utils/ndk";

function getEventRelaySet(hasTeaser: boolean, wideDistribution: boolean, relaySet: NDKRelaySet | undefined) {
    if (!hasTeaser && wideDistribution)
        return undefined;
    else
        return relaySet || getDefaultRelaySet();
}

export async function publishToTiers(
    event: NDKEvent,
    tiers: Record<string, boolean>,
    opts: {
        wideDistribution?: boolean,
        teaserEvent?: NDKEvent,
        ndk?: NDK,
        relaySet?: NDKRelaySet,
    } = {}
) {
    const ndk = opts.ndk ?? event.ndk!;
    const teaser = opts.teaserEvent;

    opts.relaySet = getEventRelaySet(!!opts.teaserEvent, !!opts.wideDistribution, opts.relaySet);

    console.log({opts});

    const user: NDKUser = await ndk.signer!.user();

    // remove signature
    event.sig = undefined;
    if (teaser) teaser.sig = undefined;

    // update created_at date
    event.created_at = Math.floor(Date.now() / 1000);
    if (teaser) teaser.created_at = Math.floor(Date.now() / 1000);

    if (!event.tagValue("h")) {
        // Add NIP-29 group `h` tag
        event.tags.push(
            ["h", user.pubkey ]
        )
    }

    if (teaser && !teaser.tagValue("h")) {
        // Add NIP-29 group `h` tag
        teaser.tags.push(
            ["h", user.pubkey ]
        )
    }

    // Annotate the tiers
    for (const tier in tiers) {
        if (teaser) {
            if (tiers[tier]) { // If this tier is required, mark is such
                teaser.tags.push(["tier", tier]);
            } else { // Otherwise, mark it for indexing
                teaser.tags.push(["f", tier]);
            }
        }

        if (!tiers[tier]) continue;
        event.tags.push(["f", tier]);
    }

    // Add pubkey and `d` tags if appropriate
    event.pubkey = user.pubkey;
    if (event.isParamReplaceable() && !event.tagValue("d")) await event.generateTags();
    if (teaser) {
        teaser.pubkey = user.pubkey;
        if (teaser.isParamReplaceable() && !teaser.tagValue("d")) await teaser.generateTags();
    }

    if (teaser) {
        event.tags.push(["preview", teaser.tagId()]);

        if (event.isParamReplaceable()) {
            teaser.tags.push(["full", event.tagId()]);
        }

        const teaserRelaySet = opts.wideDistribution ? undefined : opts.relaySet;

        await teaser.sign();

        await teaser.publish(teaserRelaySet);

        console.log('teaser', teaser.rawEvent());
        console.log({teaserRelaySet: teaserRelaySet ? teaserRelaySet.size() : 'undefined'});
    }

    await event.sign();
    await event.publish(opts.relaySet);

    console.log('event', event.rawEvent());
    console.log({relaySet: opts.relaySet ? opts.relaySet.size() : 'undefined'});
}
