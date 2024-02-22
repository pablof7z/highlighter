import NDK, { Hexpubkey, NDKEvent, NDKKind, NDKList, NDKRelaySet, NDKSigner, NDKSimpleGroup, NDKUser, type NostrEvent } from "@nostr-dev-kit/ndk";
import createDebug from "debug";

const d = createDebug("HL:nip29");

export async function createGroup(
    ndk: NDK,
    owner: NDKUser,
    name?: string,
    picture?: string,
    relaySet?: NDKRelaySet,
    signer?: NDKSigner
) {
    d("Creating group", owner.pubkey);

    const createEvent = new NDKEvent(ndk, {
        kind: NDKKind.GroupAdminEditStatus,
        tags: [
            [ "h", owner.pubkey ],
            [ "private" ],
            [ "closed" ],
        ]
    } as NostrEvent);

    await createEvent.sign(signer);
    const relays = await createEvent.publish(relaySet);
    if (relays.size === 0) {
        throw new Error("No relays available");
    }

    // if name or picture is provided, update the group
    if (name || picture) {
        d("Updating group metadata", owner.pubkey, { name, picture });
        const groupMetadataEvent = new NDKEvent(ndk, {
            kind: NDKKind.GroupAdminEditMetadata,
            tags: [
                [ "h", owner.pubkey ],
            ]
        } as NostrEvent);

        if (name) groupMetadataEvent.tags.push(["name", name]);
        if (picture) groupMetadataEvent.tags.push(["picture", picture]);

        await groupMetadataEvent.publish(relaySet);
    }
}

/**
 * This function executes in the context of the backend
 * @param groupId GroupId to add member to
 * @param member Pubkey of the member to add
 */
export async function addGroupMember(
    ndk: NDK,
    groupId: string,
    member: Hexpubkey,
    relaySet: NDKRelaySet
) {
    if (!ndk) throw new Error("NDK or user not found");

    d("Adding member to group", groupId, member);

    const group = new NDKSimpleGroup(ndk, groupId, relaySet);
    const user = ndk.getUser({pubkey: member});
    await group.addUser(user);
}

/**
 * Marks a group so the user can easily find it later
 */
export async function bookmarkGroup(
    ndk: NDK,
    groupId: string,
    relays: string[],
    list?: NDKList
) {
    if (!ndk) throw new Error("NDK or user not found");

    if (!list) {
        list = new NDKList(ndk);
        list.kind = NDKKind.SimpleGroupList;
    }

    const tag = ["group", groupId, ...relays];
    const stag = JSON.stringify(tag);

    // make sure we don't already have the group in the list
    if (list!.tags.find(t => JSON.stringify(t) === stag)) {
        return;
    }

    list!.tags.push(tag);

    return await list!.publish();
}

export default {
    createGroup,
    addGroupMember,
};