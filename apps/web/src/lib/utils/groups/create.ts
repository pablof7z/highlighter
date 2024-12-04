import { get } from "svelte/store";
import { ndk } from "../../stores/ndk";
import { NDKEvent, NDKKind, NDKRelaySet, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
import currentUser from "$stores/currentUser";

type Roles = string[];

async function createGroup(
    groupId: string,
    relays: string[],
    name: string,
    picture: string,
    about: string,
    adminPubkeys: Record<string, Roles> = {}
) {
    const $ndk = get(ndk);
    const relaySet = NDKRelaySet.fromRelayUrls(relays, $ndk);
    const group = new NDKSimpleGroup($ndk, relaySet);
    group.groupId = groupId;
    const published = await group.createGroup();
    if (!published) throw new Error("Failed to create group");

    await group.setMetadata({ name, picture, about });

    const $currentUser = get(currentUser);

    for (const adminPubkey of Object.keys(adminPubkeys)) {
        if (adminPubkey === $currentUser?.pubkey) continue;
        let event = new NDKEvent($ndk);
        event.kind = NDKKind.GroupAdminAddUser;
        event.tags.push(["h", group.groupId]);
        event.tags.push(["p", adminPubkey]);
        await event.publish(group.relaySet);

        event = new NDKEvent($ndk);
        event.kind = 9000;
        event.tags.push(["h", group.groupId]);
        event.tags.push(["p", adminPubkey, ...adminPubkeys[adminPubkey]]);
        await event.publish(group.relaySet);
    }

    return group;
}

export default createGroup;