// import { currentUser } from "@/state/current-user.svelte";
// import { ndk } from "@/state/ndk";
// import { dvmSchedule, NDKArticle, NDKDraft, NDKEvent, NDKKind, NDKRelaySet, type Hexpubkey, type NostrEvent } from "@nostr-dev-kit/ndk";
// import type { Editor } from "svelte-tiptap";

// export type EditorType = 'article' | 'thread';




// /**
//  * Publishes the event and deletes the draft(s) if they exist
//  * @param state 
//  */
// export async function publish(state: PostState): Promise<NDKEvent | NDKDraft> {
//     const events = state.generateEvents();
//     const relaySet = NDKRelaySet.fromRelayUrls(state.relays, ndk);

//     if (state.proposalRecipient) {
//         await state.generateDraft();
//         return state.draft!;
//     } else if (state.publishAt) {
//         for (const event of events) {   
//             const dvmUser = ndk.getUser({npub: 'npub1shpq6dmqaa8pjas8rftflvmr7nlssm9fqanflw23vlxu2vzexngslu90nm'});
//             event.created_at = Math.floor(new Date(state.publishAt).getTime() / 1000);
//             await event.sign();
//             const confirm = await dvmSchedule(event, dvmUser, undefined, true, 3000);
//             if (confirm) {
//                 deleteDrafts(state);
//             }
//         }
//     } else {
//         for (const event of events) {
//             await event.publish(relaySet);
//         }
//         deleteDrafts(state);
//     }

//     return events[0];
// }

// async function deleteDrafts(state: PostState) {
//     if (!state.draft) return;

//     // Get checkpoints
//     // TODO: Need to check on the draft relays
//     const checkpoints = await ndk.fetchEvents({
//         kinds: [NDKKind.DraftCheckpoint],
//         "#a": [state.draft.tagId()],
//         authors: [state.draft.pubkey]
//     });

//     await state.draft.delete();

//     if (checkpoints.size > 0) {
//         const deleteEvent = new NDKEvent(ndk, {
//             kind: NDKKind.EventDeletion,
//             tags: Array.from(checkpoints).map(c => c.tagReference())
//         } as NostrEvent);

//         await deleteEvent.sign();

//         await deleteEvent.publish();
//     }
// }